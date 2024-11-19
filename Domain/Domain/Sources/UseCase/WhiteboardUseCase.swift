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
    private var participantsInfo: [Profile] = []
    private let whiteboardListSubject: PassthroughSubject<[Whiteboard], Never>
    public let whiteboardListPublisher: AnyPublisher<[Whiteboard], Never>

    public init(repository: WhiteboardRepositoryInterface, profile: Profile) {
        self.repository = repository
        whiteboardListSubject = PassthroughSubject<[Whiteboard], Never>()
        whiteboardListPublisher = whiteboardListSubject.eraseToAnyPublisher()
        participantsInfo.append(profile)
        self.repository.delegate = self
    }

    public func createWhiteboard(nickname: String) -> Whiteboard {
        return Whiteboard(name: nickname)
    }

    public func startPublishingWhiteboard() {
        repository.startPublishing(with: participantsInfo)
    }

    public func startSearchingWhiteboard() {
        repository.startSearching()
    }
}

extension WhiteboardUseCase: WhiteboardRepositoryDelegate {
    public func whiteboardRepository(_ sender: WhiteboardRepositoryInterface, didFind whiteboards: [Whiteboard]) {
        whiteboardListSubject.send(whiteboards)
    }
}
