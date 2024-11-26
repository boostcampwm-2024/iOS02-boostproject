//
//  WhiteboardObjectSendUseCase.swift
//  Domain
//
//  Created by 박승찬 on 11/14/24.
//

public final class WhiteboardObjectSendUseCase: WhiteObjectSendUseCaseInterface {
    private let repository: WhiteboardObjectRepositoryInterface

    public init(repository: WhiteboardObjectRepositoryInterface) {
        self.repository = repository
    }

    public func send(whiteboardObject: WhiteboardObject) {
        Task {
            await repository.send(whiteboardObject: whiteboardObject, isDeleted: true)
        }
    }
}
