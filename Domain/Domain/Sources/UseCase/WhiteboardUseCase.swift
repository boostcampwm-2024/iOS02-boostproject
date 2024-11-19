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
    private let whiteboardListSubject: PassthroughSubject<[WhiteboardListEntity], Never>
    public let whiteboardListPublisher: AnyPublisher<[WhiteboardListEntity], Never>

    public init(repository: WhiteboardRepositoryInterface, profile: Profile) {
        self.repository = repository
        whiteboardListSubject = PassthroughSubject<[WhiteboardListEntity], Never>()
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

    public func joinWhiteboard(whiteboard: WhiteboardListEntity) throws {
        try repository.joinWhiteboard(whiteboard: whiteboard)
    }
}

extension WhiteboardUseCase: WhiteboardRepositoryDelegate {
    public func whiteboardRepository(
        _ sender: WhiteboardRepositoryInterface,
        didFind whiteboards: [WhiteboardListEntity]
    ) {
        whiteboardListSubject.send(whiteboards)
    }
}
