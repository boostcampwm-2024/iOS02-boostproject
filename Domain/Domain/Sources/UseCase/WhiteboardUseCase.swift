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
    private let whiteboardListSubject: CurrentValueSubject<[Whiteboard], Never>
    public let whiteboardListPublisher: AnyPublisher<[Whiteboard], Never>
    private let whiteboardConnectionSubject: PassthroughSubject<Bool, Never>
    public let whiteboardConnectionPublisher: AnyPublisher<Bool, Never>
    private var cancellables: Set<AnyCancellable>

    public init(
        whiteboardRepository: WhiteboardRepositoryInterface,
        profileRepository: ProfileRepositoryInterface
    ) {
        self.whiteboardRepository = whiteboardRepository
        self.profileRepository = profileRepository
        whiteboardListSubject = CurrentValueSubject<[Whiteboard], Never>([])
        whiteboardListPublisher = whiteboardListSubject.eraseToAnyPublisher()
        whiteboardConnectionSubject = PassthroughSubject<Bool, Never>()
        whiteboardConnectionPublisher = whiteboardConnectionSubject.eraseToAnyPublisher()
        cancellables = []
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
        let myProfile = profileRepository.loadProfile()
        whiteboardRepository.startPublishing(myProfile: myProfile)
    }

    public func stopSearchingWhiteboard() {
        whiteboardRepository.stopSearching()
    }

    public func disconnectWhiteboard() {
        whiteboardRepository.disconnectWhiteboard()
    }

    public func joinWhiteboard(whiteboard: Whiteboard) throws {
        let profile = profileRepository.loadProfile()
        bindConnectionResult()
        try whiteboardRepository.joinWhiteboard(whiteboard: whiteboard, myProfile: profile)
    }

    public func startSearchingWhiteboards() {
        whiteboardRepository.startSearching()
    }

    private func bindConnectionResult() {
        whiteboardRepository.connectionResultPublisher
            .timeout(.seconds(3), scheduler: DispatchQueue.main)
            .first()
            .replaceEmpty(with: false)
            .sink { [weak self] isConnected in
                if isConnected {
                    self?.whiteboardConnectionSubject.send(true)
                } else {
                    self?.whiteboardConnectionSubject.send(false)
                }
            }
            .store(in: &cancellables)
    }
}

extension WhiteboardUseCase: WhiteboardRepositoryDelegate {
    public func whiteboardRepository(
        _ sender: WhiteboardRepositoryInterface,
        didFind whiteboards: [Whiteboard]
    ) {
        whiteboardListSubject.send(whiteboards)
    }

    public func whiteboardRepository(_ sender: any WhiteboardRepositoryInterface, didLost whiteboardId: UUID) {
        let updatedWhiteboards = whiteboardListSubject
            .value
            .filter { $0.id != whiteboardId }
        whiteboardListSubject.send(updatedWhiteboards)
    }
}
