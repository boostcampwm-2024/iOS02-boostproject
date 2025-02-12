//
//  ManageWhiteboardObjectUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/16/24.
//

import Combine
import Foundation

public final class WhiteboardUseCase: WhiteboardUseCaseInterface {
    public var addedObjectPublisher: AnyPublisher<WhiteboardObject, Never>
    public var updatedObjectPublisher: AnyPublisher<WhiteboardObject, Never>
    public var removedObjectPublisher: AnyPublisher<WhiteboardObject, Never>
    public var selectedObjectIDPublisher: AnyPublisher<UUID?, Never>
    private let addedWhiteboardSubject: PassthroughSubject<WhiteboardObject, Never>
    private let updatedWhiteboardSubject: PassthroughSubject<WhiteboardObject, Never>
    private let removedWhiteboardSubject: PassthroughSubject<WhiteboardObject, Never>
    private let selectedObjectIDSubject: CurrentValueSubject<UUID?, Never>
    private var whiteboardRepository: WhiteboardRepositoryInterface
    private let profileRepository: ProfileRepositoryInterface
    private var whiteboardObjectSet: WhiteboardObjectSetInterface
    private var whiteboard: Whiteboard?
    private var cancellables: Set<AnyCancellable>

    public init(
        profileRepository: ProfileRepositoryInterface,
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

        self.whiteboardRepository = whiteboardRepository
        self.profileRepository = profileRepository
        self.whiteboardObjectSet = whiteboardObjectSet
        cancellables = []
        self.whiteboardRepository.delegate = self
    }

    public func configure(with whiteboard: Whiteboard) {
        self.whiteboard = whiteboard
    }

    @discardableResult
    public func addObject(whiteboardObject: WhiteboardObject, isReceivedObject: Bool) async -> Bool {
        guard await !whiteboardObjectSet.contains(object: whiteboardObject) else { return false }

        await whiteboardObjectSet.insert(object: whiteboardObject)
        addedWhiteboardSubject.send(whiteboardObject)

        if !isReceivedObject {
            return await whiteboardRepository.send(whiteboardObject: whiteboardObject, isDeleted: false)
        }

        return true
    }

    @discardableResult
    public func updateObject(whiteboardObject: WhiteboardObject, isReceivedObject: Bool) async -> Bool {
        guard await whiteboardObjectSet.contains(object: whiteboardObject) else { return false }

        await whiteboardObjectSet.update(object: whiteboardObject)
        updatedWhiteboardSubject.send(whiteboardObject)

        if !isReceivedObject {
            return await whiteboardRepository.send(whiteboardObject: whiteboardObject, isDeleted: false)
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
            return await whiteboardRepository.send(whiteboardObject: object, isDeleted: true)
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
        selectedObjectIDSubject.send(whiteboardObjectID)

        return await updateObject(whiteboardObject: object, isReceivedObject: false)
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
        return await updateObject(whiteboardObject: selectedObject, isReceivedObject: false)
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

    public func disconnectWhiteboard() {
        Task {
            await whiteboardObjectSet.removeAll()
            whiteboard = nil
            whiteboardRepository.disconnectWhiteboard()
        }
    }

    // 추후 고도화한다면, 전송 실패한 오브젝트만 따로 재전송하는 등의 작업이 가능할 듯
    private func sendAllWhiteboardObjects(to profile: Profile) {
        Task {
            let objects = await self.whiteboardObjectSet.fetchAll()
            let chunckedObjects = stride(from: 0, to: objects.count, by: 3).map {
                Array(objects[$0..<min($0 + 3, objects.count)])
            }

            for chuncked in chunckedObjects {
                _ = await whiteboardRepository.send(whiteboardObjects: chuncked, to: profile)
            }
        }
    }
}

extension WhiteboardUseCase: WhiteboardRepositoryDelegate {
    public func whiteboardRepository(_ sender: any WhiteboardRepositoryInterface, newPeer: Profile) {
        let myProfile = profileRepository.loadProfile()

        guard
            var whiteboard,
            whiteboard.id == myProfile.id
        else { return }

        sendAllWhiteboardObjects(to: newPeer)

        whiteboard.participantIcons.append(newPeer.profileIcon)
        self.whiteboard = whiteboard
        whiteboardRepository.republish(whiteboard: whiteboard)
    }

    public func whiteboardRepository(
        _ sender: any WhiteboardRepositoryInterface,
        lostPeer: Profile
    ) {
        let myProfile = profileRepository.loadProfile()

        guard
            var whiteboard,
            whiteboard.id == myProfile.id
        else { return }

        var participantIcons = whiteboard.participantIcons

        guard let participantIndex = participantIcons.firstIndex(where: { $0 == lostPeer.profileIcon })
        else { return }

        participantIcons.remove(at: participantIndex)
        whiteboard.participantIcons = participantIcons
        self.whiteboard = whiteboard
        whiteboardRepository.republish(whiteboard: whiteboard)
    }

    public func whiteboardRepository(
        _ sender: any WhiteboardRepositoryInterface,
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

    public func whiteboardRepository(
        _ sender: any WhiteboardRepositoryInterface,
        didDelete object: WhiteboardObject
    ) {
        Task {
            await removeObject(whiteboardObjectID: object.id, isReceivedObject: true)
        }
    }

    public func whiteboardRepository(
        _ sender: any WhiteboardRepositoryInterface,
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
}
