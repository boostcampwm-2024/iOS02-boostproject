//
//  WhiteboardUseCase.swift
//  Domain
//
//  Created by 최다경 on 11/12/24.
//

import Combine
import Foundation

public final class WhiteboardUseCase: WhiteboardUseCaseInterface {
    private var whiteboardRepository: WhiteboardRepositoryInterface
    private var profileRepository: ProfileRepositoryInterface
    private let whiteboardListSubject: PassthroughSubject<[Whiteboard], Never>
    public let whiteboardListPublisher: AnyPublisher<[Whiteboard], Never>

    public init(
        whiteboardRepository: WhiteboardRepositoryInterface,
        profileRepository: ProfileRepositoryInterface
    ) {
        self.whiteboardRepository = whiteboardRepository
        self.profileRepository = profileRepository
        whiteboardListSubject = PassthroughSubject<[Whiteboard], Never>()
        whiteboardListPublisher = whiteboardListSubject.eraseToAnyPublisher()
        self.whiteboardRepository.delegate = self
    }

    public func createWhiteboard() -> Whiteboard {
        let profile = profileRepository.loadProfile()
        return Whiteboard(
            id: UUID(),
            name: profile.nickname,
            participantIcons: [profile.profileIcon])
    }

    public func startPublishingWhiteboard() {
        let profile = profileRepository.loadProfile()
        whiteboardRepository.startPublishing(with: [profile])
    }

    public func startSearchingWhiteboard() {
        whiteboardRepository.startSearching()
    }

    public func stopSearchingWhiteboard() {
        whiteboardRepository.stopSearching()
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
