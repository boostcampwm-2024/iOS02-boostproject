//
//  WhiteboardUseCase.swift
//  Domain
//
//  Created by 최다경 on 11/12/24.
//

public final class WhiteboardUseCase: WhiteboardUseCaseInterface {
    private let repository: WhiteboardRepositoryInterface

    public init(repository: WhiteboardRepositoryInterface) {
        self.repository = repository
    }

    public func createWhiteboard(nickname: String) -> Whiteboard {
        return Whiteboard(name: nickname)
    }

    public func startPublishingWhiteboard() {
        repository.startPublishing()
    }
}
