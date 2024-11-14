//
//  WhiteboardUseCase.swift
//  Domain
//
//  Created by 최다경 on 11/12/24.
//

public final class WhiteboardUseCase: WhiteboardUseCaseInterface {
    public var repository: WhiteboardRepositoryInterface

    public init(repository: WhiteboardRepositoryInterface) {
        self.repository = repository
    }

    public func createWhiteboard(nickname: String) -> Whiteboard {
        return repository.createWhiteboard(nickname: nickname)
    }

    public func startPublishing() {
        repository.startPublishing()
    }
}
