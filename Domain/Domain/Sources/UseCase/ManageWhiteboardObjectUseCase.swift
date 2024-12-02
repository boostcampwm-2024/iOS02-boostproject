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

    private let addedWhiteboardSubject: PassthroughSubject<WhiteboardObject, Never>
    private let updatedWhiteboardSubject: PassthroughSubject<WhiteboardObject, Never>
    private let removedWhiteboardSubject: PassthroughSubject<WhiteboardObject, Never>
    private let selectedObjectIDSubject: CurrentValueSubject<UUID?, Never>
    private let whiteboardRepository: WhiteboardRepositoryInterface
    private let profileRepository: ProfileRepositoryInterface
    private var whiteboardObjectRepository: WhiteboardObjectRepositoryInterface
    private var whiteboardObjectSet: WhiteboardObjectSetInterface
    private var cancellables: Set<AnyCancellable>

    public init(
        profileRepository: ProfileRepositoryInterface,
        whiteboardObjectRepository: WhiteboardObjectRepositoryInterface,
        whiteboardRepository: WhiteboardRepositoryInterface,
        whiteboardObjectSet: WhiteboardObjectSetInterface
    ) {
        addedWhiteboardSubject = PassthroughSubject<WhiteboardObject, Never>()
        updatedWhiteboardSubject = PassthroughSubject<WhiteboardObject, Never>()
        removedWhiteboardSubject = PassthroughSubject<WhiteboardObject, Never>()
        selectedObjectIDSubject = CurrentValueSubject<UUID?, Never>(nil)

        addedObjectPublisher = addedWhiteboardSubject.eraseToAnyPublisher()
        updatedObjectPublisher = updatedWhiteboardSubject.eraseToAnyPublisher()
        removedObjectPublisher = removedWhiteboardSubject.eraseToAnyPublisher()
        selectedObjectIDPublisher = selectedObjectIDSubject.eraseToAnyPublisher()

        self.whiteboardObjectSet = whiteboardObjectSet
        self.whiteboardObjectRepository = whiteboardObjectRepository
        self.whiteboardRepository = whiteboardRepository
        self.profileRepository = profileRepository
        cancellables = []
        self.whiteboardObjectRepository.delegate = self

        bindWhiteboardRepository()
    }

    @discardableResult
    public func addObject(whiteboardObject: WhiteboardObject, isReceivedObject: Bool) async -> Bool {
        guard await !whiteboardObjectSet.contains(object: whiteboardObject) else { return false }

        await whiteboardObjectSet.insert(object: whiteboardObject)
        addedWhiteboardSubject.send(whiteboardObject)

        if !isReceivedObject {
            await whiteboardObjectRepository.send(whiteboardObject: whiteboardObject, isDeleted: false)
        }

        return true
    }

    @discardableResult
    public func updateObject(whiteboardObject: WhiteboardObject, isReceivedObject: Bool) async -> Bool {
        guard await whiteboardObjectSet.contains(object: whiteboardObject) else { return false }

        await whiteboardObjectSet.update(object: whiteboardObject)
        updatedWhiteboardSubject.send(whiteboardObject)

        if !isReceivedObject {
            await whiteboardObjectRepository.send(whiteboardObject: whiteboardObject, isDeleted: false)
        }

        return true
    }

    @discardableResult
    public func removeObject(whiteboardObjectID: UUID, isReceivedObject: Bool) async -> Bool {
        guard
            let object = await whiteboardObjectSet.fetchObjectByID(id: whiteboardObjectID)
        else { return false }

        await whiteboardObjectSet.remove(object: object)
        removedWhiteboardSubject.send(object)

        if !isReceivedObject {
            let myProfile = profileRepository.loadProfile()
            guard object.selectedBy == myProfile else { return false }
            await whiteboardObjectRepository.send(whiteboardObject: object, isDeleted: true)
        }

        return true
    }

    @discardableResult
    public func select(whiteboardObjectID: UUID) async -> Bool {
        await deselect()

        guard
            let object = await whiteboardObjectSet.fetchObjectByID(id: whiteboardObjectID),
            object.selectedBy == nil
        else { return false }

        let myProfile = profileRepository.loadProfile()
        object.select(by: myProfile)
        await updateObject(whiteboardObject: object, isReceivedObject: false)
        selectedObjectIDSubject.send(whiteboardObjectID)
        return true
    }

    @discardableResult
    public func deselect() async -> Bool {
        let myProfile = profileRepository.loadProfile()
        guard let selectedObjectID = selectedObjectIDSubject.value else { return false }

        guard
            let selectedObject = await whiteboardObjectSet.fetchObjectByID(id: selectedObjectID),
            selectedObject.selectedBy == myProfile
        else { return false }

        selectedObject.deselect()
        await updateObject(whiteboardObject: selectedObject, isReceivedObject: false)
        return true
    }

    @discardableResult
    public func changeSizeAndAngle(
        whiteboardObjectID: UUID,
        scale: CGFloat,
        angle: CGFloat
    ) async -> Bool {
        let myProfile = profileRepository.loadProfile()
        guard
            let object = await whiteboardObjectSet.fetchObjectByID(id: whiteboardObjectID),
            object.selectedBy == myProfile
        else { return false }

        object.changeScale(to: scale)
        object.changeAngle(to: angle)

        return await updateObject(whiteboardObject: object, isReceivedObject: false)
    }

    @discardableResult
    public func changePosition(whiteboardObjectID: UUID, to position: CGPoint) async -> Bool {
        let myProfile = profileRepository.loadProfile()
        guard
            let object = await whiteboardObjectSet.fetchObjectByID(id: whiteboardObjectID),
            object.selectedBy == myProfile
        else { return false }

        object.changePosition(position: position)
        return await updateObject(whiteboardObject: object, isReceivedObject: false)
    }

    private func bindWhiteboardRepository() {
        whiteboardRepository.recentPeerPublisher
            .sink { [weak self] profile in
                self?.sendAllWhiteboardObjects(to: profile)
            }
            .store(in: &cancellables)
    }

    private func sendAllWhiteboardObjects(to profile: Profile) {
        Task {
            let objects = await self.whiteboardObjectSet.fetchAll()
            let chunckedObjects = stride(from: 0, to: objects.count, by: 5).map {
                Array(objects[$0..<min($0 + 5, objects.count)])
            }

            for chuncked in chunckedObjects {
                await whiteboardObjectRepository.send(
                    whiteboardObjects: chuncked,
                    isDeleted: false,
                    to: profile)
            }
        }
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

            await updateObject(whiteboardObject: photoObject, isReceivedObject: true)
        }
    }

    public func whiteboardObjectRepository(
        _ sender: any WhiteboardObjectRepositoryInterface,
        didReceive object: WhiteboardObject
    ) {
        Task {
            let isContains = await whiteboardObjectSet.contains(object: object)

            if isContains {
                await updateObject(whiteboardObject: object, isReceivedObject: true)
            } else {
                await addObject(whiteboardObject: object, isReceivedObject: true)
            }
        }
    }

    public func whiteboardObjectRepository(
        _ sender: any WhiteboardObjectRepositoryInterface,
        didDelete object: WhiteboardObject
    ) {
        Task {
            await removeObject(whiteboardObjectID: object.id, isReceivedObject: true)
        }
    }
}
