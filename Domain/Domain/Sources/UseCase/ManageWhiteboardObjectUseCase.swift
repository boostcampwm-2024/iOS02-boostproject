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

    private var whiteboardObjects: [WhiteboardObject]

    private let addedWhiteboardSubject: PassthroughSubject<WhiteboardObject, Never>
    private let updatedWhiteboardSubject: PassthroughSubject<WhiteboardObject, Never>
    private let removedWhiteboardSubject: PassthroughSubject<WhiteboardObject, Never>
    private let selectedObjectIDSubject: CurrentValueSubject<UUID?, Never>
    private let whiteboardRepository: WhiteboardObjectRepositoryInterface
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

        whiteboardObjects = []
        myProfile = profileRepository.loadProfile()
        self.whiteboardRepository = whiteboardRepository
    }

    @discardableResult
    public func addObject(whiteboardObject: WhiteboardObject) -> Bool {
        guard !whiteboardObjects.contains(whiteboardObject) else { return  false }

        Task {
            await whiteboardRepository.send(whiteboardObject: whiteboardObject, isDeleted: false)
            whiteboardObjects.append(whiteboardObject)
            addedWhiteboardSubject.send(whiteboardObject)
        }
        
        return true
    }

    @discardableResult
    public func updateObject(whiteboardObject: WhiteboardObject) -> Bool {
        guard let index = whiteboardObjects.firstIndex(where: { $0 == whiteboardObject }) else { return false }

        Task {
            await whiteboardRepository.send(whiteboardObject: whiteboardObject, isDeleted: false)
            whiteboardObjects[index] = whiteboardObject
            updatedWhiteboardSubject.send(whiteboardObject)
        }

        return true
    }

    @discardableResult
    public func removeObject(whiteboardObject: WhiteboardObject) -> Bool {
        guard whiteboardObjects.contains(whiteboardObject) else { return false }

        Task {
            await whiteboardRepository.send(whiteboardObject: whiteboardObject, isDeleted: true)
            whiteboardObjects.removeAll { $0 == whiteboardObject }
            removedWhiteboardSubject.send(whiteboardObject)
        }

        return true
    }

    public func select(whiteboardObjectID: UUID) {
        deselect()

        guard
            let object = whiteboardObjects.first(where: { $0.id == whiteboardObjectID }),
            object.selectedBy == nil
        else { return }

        object.select(by: myProfile)
        updateObject(whiteboardObject: object)
        selectedObjectIDSubject.send(whiteboardObjectID)
    }

    public func deselect() {
        guard
            let selectedObjectID = selectedObjectIDSubject.value,
            let object = whiteboardObjects.first(where: { $0.id == selectedObjectID }),
            object.selectedBy == myProfile
        else { return }

        object.deselect()
        updateObject(whiteboardObject: object)
    }
}

extension ManageWhiteboardObjectUseCase: WhiteboardObjectRepositoryDelegate {
    public func whiteboardObjectRepository(
        _ sender: any WhiteboardObjectRepositoryInterface,
        didReceive object: WhiteboardObject
    ) {
        if whiteboardObjects.contains(object) {
            updateObject(whiteboardObject: object)
        } else {
            addObject(whiteboardObject: object)
        }
    }
    
    public func whiteboardObjectRepository(_ sender: any WhiteboardObjectRepositoryInterface, didDelete object: WhiteboardObject) {
        removeObject(whiteboardObject: object)
    }
}
