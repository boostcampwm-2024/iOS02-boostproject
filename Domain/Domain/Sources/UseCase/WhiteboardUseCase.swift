//
//  WhiteboardUseCase.swift
//  Domain
//
//  Created by 최다경 on 11/12/24.
//

import Combine
import Foundation

public final class WhiteboardUseCase: WhiteboardUseCaseInterface {
    private var repository: WhiteboardRepositoryInterface
    private let profile: Profile
    private var participantsInfo: [Profile] = []
    private let whiteboardListSubject: PassthroughSubject<[Whiteboard], Never>
    public let whiteboardListPublisher: AnyPublisher<[Whiteboard], Never>

    public init(repository: WhiteboardRepositoryInterface, profile: Profile) {
        self.repository = repository
        self.profile = profile
        whiteboardListSubject = PassthroughSubject<[Whiteboard], Never>()
        whiteboardListPublisher = whiteboardListSubject.eraseToAnyPublisher()
        participantsInfo.append(profile)
        self.repository.delegate = self
    }

    public func createWhiteboard(nickname: String) -> Whiteboard {
        return Whiteboard(
            id: UUID(),
            name: nickname,
            participantIcons: [profile.profileIcon])
    }

    public func startPublishingWhiteboard() {
        repository.startPublishing(with: participantsInfo)
    }

    public func startSearchingWhiteboard() {
        repository.startSearching()
    }

    public func stopSearchingWhiteboard() {
        repository.stopSearching()
    }
}

extension WhiteboardUseCase: WhiteboardRepositoryDelegate {
    public func whiteboardRepository(
        _ sender: WhiteboardRepositoryInterface,
        didFind whiteboards: [Whiteboard]
    ) {
        whiteboardListSubject.send(whiteboards)
    }
}
