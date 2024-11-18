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

    public private(set) var whiteboardListPublisher: AnyPublisher<[Whiteboard], Never>
    private let whiteboardListSubject: CurrentValueSubject<[Whiteboard], Never>

    public init(repository: WhiteboardRepositoryInterface) {
        self.repository = repository
        whiteboardListSubject = CurrentValueSubject<[Whiteboard], Never>([])
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

extension WhiteboardUseCase: WhiteboardDelegate {
    public func whiteboard(_ sender: any WhiteboardRepositoryInterface, didFind whiteboards: [Whiteboard]) {
        whiteboardListSubject.send(whiteboards)
    }
}
