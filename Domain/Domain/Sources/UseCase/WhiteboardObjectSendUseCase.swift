//
//  WhiteboardObjectSendUseCase.swift
//  Domain
//
//  Created by 박승찬 on 11/14/24.
//

public final class WhiteboardObjectSendUseCase: WhiteObjectSendUseCaseInterface {
    private let repository: WhiteboardObjectRepositoryInterface

    init(repository: WhiteboardObjectRepositoryInterface) {
        self.repository = repository
    }

    public func send(whiteboardObject: WhiteboardObject) {
        repository.send(whiteboardObject: whiteboardObject)
    }
}
