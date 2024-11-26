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

    private var whiteboardObjectSet: WhiteboardObjectSet

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

        whiteboardObjectSet = WhiteboardObjectSet()
        myProfile = profileRepository.loadProfile()
        self.whiteboardObjectRepository = whiteboardRepository
    }

    @discardableResult
    public func addObject(whiteboardObject: WhiteboardObject) async -> Bool {
        guard await !whiteboardObjectSet.contains(object: whiteboardObject) else { return false }

        await whiteboardObjectRepository.send(whiteboardObject: whiteboardObject, isDeleted: false)
        await whiteboardObjectSet.insert(object: whiteboardObject)
        addedWhiteboardSubject.send(whiteboardObject)

        return true
    }

    @discardableResult
    public func updateObject(whiteboardObject: WhiteboardObject) async -> Bool {
        guard await whiteboardObjectSet.contains(object: whiteboardObject) else { return false }

        await whiteboardObjectRepository.send(whiteboardObject: whiteboardObject, isDeleted: false)
        await whiteboardObjectSet.update(object: whiteboardObject)
        updatedWhiteboardSubject.send(whiteboardObject)

        return true
    }

    @discardableResult
    public func removeObject(whiteboardObjectID: UUID) async -> Bool {
        guard
            let object = await whiteboardObjectSet.fetchObjectByID(id: whiteboardObjectID),
            object.selectedBy == myProfile
        else { return false }

        await whiteboardObjectSet.remove(object: object)
        await whiteboardObjectRepository.send(whiteboardObject: object, isDeleted: true)
        removedWhiteboardSubject.send(object)

        return true
    }

    @discardableResult
    public func select(whiteboardObjectID: UUID) async -> Bool {
        await deselect()

        guard
            let object = await whiteboardObjectSet.fetchObjectByID(id: whiteboardObjectID),
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
            let selectedObject = await whiteboardObjectSet.fetchObjectByID(id: selectedObjectID),
            selectedObject.selectedBy == myProfile
        else { return false }

        selectedObject.deselect()
        await updateObject(whiteboardObject: selectedObject)
        return true
    }

    @discardableResult
    public func changeSizeAndAngle(
        whiteboardObjectID: UUID,
        scale: CGFloat,
        angle: CGFloat
    ) async -> Bool {
        guard
            let object = await whiteboardObjectSet.fetchObjectByID(id: whiteboardObjectID),
            object.selectedBy == myProfile
        else { return false }

        object.changeScale(to: scale)
        object.changeAngle(to: angle)

        return await updateObject(whiteboardObject: object)
    }

    @discardableResult
    public func changePosition(whiteboardObjectID: UUID, to position: CGPoint) async -> Bool {
        guard
            let object = await whiteboardObjectSet.fetchObjectByID(id: whiteboardObjectID),
            object.selectedBy == myProfile
        else { return false }

        object.changePosition(position: position)
        return await updateObject(whiteboardObject: object)
    }
}

extension ManageWhiteboardObjectUseCase: WhiteboardObjectRepositoryDelegate {
    public func whiteboardObjectRepository(
        _ sender: any WhiteboardObjectRepositoryInterface,
        didReceive photoID: UUID,
        savedURL: URL
    ) {
        Task {
            guard
                let photoObject = await whiteboardObjectSet
                    .fetchObjectByID(id: photoID) as? PhotoObject
            else { return }
            await updateObject(whiteboardObject: photoObject)
        }
    }

    public func whiteboardObjectRepository(
        _ sender: any WhiteboardObjectRepositoryInterface,
        didReceive object: WhiteboardObject
    ) {
        Task {
            let isContains = await whiteboardObjectSet.contains(object: object)

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
            await removeObject(whiteboardObjectID: object.id)
        }
    }
}
