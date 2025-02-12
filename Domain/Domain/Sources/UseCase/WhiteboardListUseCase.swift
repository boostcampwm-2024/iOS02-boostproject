//
//  WhiteboardUseCase.swift
//  Domain
//
//  Created by 최다경 on 11/12/24.
//

import Combine
import Foundation

public final class WhiteboardListUseCase: WhiteboardListUseCaseInterface {
    public let whiteboardListPublisher: AnyPublisher<[Whiteboard], Never>
    private let whiteboardListSubject: CurrentValueSubject<[Whiteboard], Never>
    private var whiteboardListRepository: WhiteboardListRepositoryInterface
    private var profileRepository: ProfileRepositoryInterface
    private var cancellables: Set<AnyCancellable>

    public init(
        whiteboardListRepository: WhiteboardListRepositoryInterface,
        profileRepository: ProfileRepositoryInterface
    ) {
        self.whiteboardListRepository = whiteboardListRepository
        self.profileRepository = profileRepository
        whiteboardListSubject = CurrentValueSubject<[Whiteboard], Never>([])
        whiteboardListPublisher = whiteboardListSubject.eraseToAnyPublisher()
        cancellables = []
        self.whiteboardListRepository.delegate = self
    }

    public func createWhiteboard() -> Whiteboard {
        let myProfile = profileRepository.loadProfile()
        startPublishingWhiteboard()
        return Whiteboard(
            id: myProfile.id,
            name: myProfile.nickname,
            participantIcons: [myProfile.profileIcon])
    }

    public func joinWhiteboard(whiteboard: Whiteboard) async -> Whiteboard? {
        stopSearchingWhiteboard()
        stopPublishingWhiteboard()

        let myProfile = profileRepository.loadProfile()
        let result = await whiteboardListRepository.joinWhiteboard(whiteboard: whiteboard, myProfile: myProfile)
        return result ? whiteboard : nil
    }

    public func startSearchingWhiteboards() {
        stopPublishingWhiteboard()
        stopSearchingWhiteboard()
        whiteboardListRepository.startSearching()
    }

    private func startPublishingWhiteboard() {
        stopSearchingWhiteboard()

        let myProfile = profileRepository.loadProfile()
        whiteboardListRepository.startPublishing(myProfile: myProfile, paritipantIcons: [myProfile.profileIcon])
    }

    private func stopPublishingWhiteboard() {
        whiteboardListRepository.stopPublishing()
    }

    private func stopSearchingWhiteboard() {
        whiteboardListRepository.stopSearching()
    }
}

extension WhiteboardListUseCase: WhiteboardListRepositoryDelegate {
    public func whiteboardListRepository(
        _ sender: any WhiteboardListRepositoryInterface,
        didFind whiteboard: Whiteboard
    ) {
        whiteboardListSubject.value.append(whiteboard)
    }

    public func whiteboardListRepository(
        _ sender: any WhiteboardListRepositoryInterface,
        didLost whiteboard: Whiteboard
    ) {
        let updatedWhiteboards = whiteboardListSubject
            .value
            .filter { $0.id != whiteboard.id }
        whiteboardListSubject.send(updatedWhiteboards)
    }
}
