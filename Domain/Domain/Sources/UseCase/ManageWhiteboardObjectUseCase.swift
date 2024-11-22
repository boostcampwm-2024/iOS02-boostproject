//
//  ManageWhiteboardObjectUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/16/24.
//

import Combine
import Foundation

public final class ManageWhiteboardObjectUseCase: ManageWhiteboardObjectUseCaseInterface {
    public var addedObjectPublisher: AnyPublisher<WhiteboardObject, Never>
    public var updatedObjectPublisher: AnyPublisher<WhiteboardObject, Never>
    public var removedObjectPublisher: AnyPublisher<WhiteboardObject, Never>
    public var selectedObjectIDPublisher: AnyPublisher<UUID?, Never>

    private var whiteboardObjectStorage: WhiteboardObjectStorage

    private let addedWhiteboardSubject: PassthroughSubject<WhiteboardObject, Never>
    private let updatedWhiteboardSubject: PassthroughSubject<WhiteboardObject, Never>
    private let removedWhiteboardSubject: PassthroughSubject<WhiteboardObject, Never>
    private let selectedObjectIDSubject: CurrentValueSubject<UUID?, Never>
    private let whiteboardObjectRepository: WhiteboardObjectRepositoryInterface
    private let myProfile: Profile

    public init(
        profileRepository: ProfileRepositoryInterface,
        whiteboardRepository: WhiteboardObjectRepositoryInterface
    ) {
        addedWhiteboardSubject = PassthroughSubject<WhiteboardObject, Never>()
        updatedWhiteboardSubject = PassthroughSubject<WhiteboardObject, Never>()
        removedWhiteboardSubject = PassthroughSubject<WhiteboardObject, Never>()
        selectedObjectIDSubject = CurrentValueSubject<UUID?, Never>(nil)

        addedObjectPublisher = addedWhiteboardSubject.eraseToAnyPublisher()
        updatedObjectPublisher = updatedWhiteboardSubject.eraseToAnyPublisher()
        removedObjectPublisher = removedWhiteboardSubject.eraseToAnyPublisher()
        selectedObjectIDPublisher = selectedObjectIDSubject.eraseToAnyPublisher()

        whiteboardObjectStorage = WhiteboardObjectStorage()
        myProfile = profileRepository.loadProfile()
        self.whiteboardObjectRepository = whiteboardRepository
    }

    @discardableResult
    public func addObject(whiteboardObject: WhiteboardObject) async -> Bool {
        let isContains = await whiteboardObjectStorage.contains(object: whiteboardObject)
        guard !isContains else { return false }

        await whiteboardObjectRepository.send(whiteboardObject: whiteboardObject, isDeleted: false)
        await whiteboardObjectStorage.insert(object: whiteboardObject)
        addedWhiteboardSubject.send(whiteboardObject)

        return true
    }

    @discardableResult
    public func updateObject(whiteboardObject: WhiteboardObject) async -> Bool {
        let isContains = await whiteboardObjectStorage.contains(object: whiteboardObject)
        guard isContains else { return false }

        await whiteboardObjectRepository.send(whiteboardObject: whiteboardObject, isDeleted: false)
        await whiteboardObjectStorage.update(object: whiteboardObject)
        updatedWhiteboardSubject.send(whiteboardObject)

        return true
    }

    @discardableResult
    public func removeObject(whiteboardObject: WhiteboardObject) async -> Bool {
        let isContains = await whiteboardObjectStorage.contains(object: whiteboardObject)
        guard isContains else { return false }

        await whiteboardObjectRepository.send(whiteboardObject: whiteboardObject, isDeleted: true)
        await whiteboardObjectStorage.remove(object: whiteboardObject)
        removedWhiteboardSubject.send(whiteboardObject)

        return true
    }

    @discardableResult
    public func select(whiteboardObjectID: UUID) async -> Bool {
        await deselect()

        guard
            let object = await whiteboardObjectStorage.fetchObjectByID(id: whiteboardObjectID),
            object.selectedBy == nil
        else { return false }

        object.select(by: myProfile)
        await updateObject(whiteboardObject: object)
        selectedObjectIDSubject.send(whiteboardObjectID)
        return true
    }

    @discardableResult
    public func deselect() async -> Bool {
        guard let selectedObjectID = selectedObjectIDSubject.value else { return false }

        guard
            let selectedObject = await whiteboardObjectStorage.fetchObjectByID(id: selectedObjectID),
            selectedObject.selectedBy == myProfile
        else { return false }

        selectedObject.deselect()
        await updateObject(whiteboardObject: selectedObject)
        return true
    }
}

extension ManageWhiteboardObjectUseCase: WhiteboardObjectRepositoryDelegate {
    public func whiteboardObjectRepository(
        _ sender: any WhiteboardObjectRepositoryInterface,
        didReceive object: WhiteboardObject
    ) {
        Task {
            let isContains = await whiteboardObjectStorage.contains(object: object)

            if isContains {
                await updateObject(whiteboardObject: object)
            } else {
                await addObject(whiteboardObject: object)
            }
        }
    }

    public func whiteboardObjectRepository(
        _ sender: any WhiteboardObjectRepositoryInterface,
        didDelete object: WhiteboardObject
    ) {
        Task {
            await removeObject(whiteboardObject: object)
        }
    }
}
