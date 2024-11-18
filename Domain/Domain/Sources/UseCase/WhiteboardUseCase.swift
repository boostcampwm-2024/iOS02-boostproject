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
    private let whiteboardListSubject: PassthroughSubject<[Whiteboard], Never>
    public let whiteboardListPublisher: AnyPublisher<[Whiteboard], Never>

    public init(repository: WhiteboardRepositoryInterface) {
        self.repository = repository
        whiteboardListSubject = PassthroughSubject<[Whiteboard], Never>()
        whiteboardListPublisher = whiteboardListSubject.eraseToAnyPublisher()
        self.repository.delegate = self
    }

    public func createWhiteboard(nickname: String) -> Whiteboard {
        return Whiteboard(name: nickname)
    }

    public func startPublishingWhiteboard() {
        repository.startPublishing()
    }

    public func startSearchingWhiteboard() {
        repository.startSearching()
    }
}

extension WhiteboardUseCase: WhiteboardRepositoryDelegate {
    public func whiteboard(_ sender: any WhiteboardRepositoryInterface, didFind whiteboards: [Whiteboard]) {
        whiteboardListSubject.send(whiteboards)
    }
}
