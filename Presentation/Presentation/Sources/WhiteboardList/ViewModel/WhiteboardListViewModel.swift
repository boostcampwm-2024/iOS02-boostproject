//
//  WhiteboardListViewModel.swift
//  Presentation
//
//  Created by 최다경 on 11/12/24.
//

import Combine
import Domain
import Foundation

public final class WhiteboardListViewModel: ViewModel {
    private let whiteboardUseCase: WhiteboardUseCaseInterface
    private var nickname: String

    enum Input {
        case createWhiteboard
    }

    struct Output {
        let whiteboardPublisher: AnyPublisher<Whiteboard, Never>
    }

    var output: Output
    let whiteboardSubject: PassthroughSubject<Whiteboard, Never>

    public init(whiteboardUseCase: WhiteboardUseCaseInterface, nickname: String) {
        self.whiteboardUseCase = whiteboardUseCase
        self.nickname = nickname
        whiteboardSubject = PassthroughSubject<Whiteboard, Never>()
        self.output = Output(whiteboardPublisher: whiteboardSubject.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .createWhiteboard:
            createWhiteboard()
        }
    }

    private func createWhiteboard() {
        let whiteboard = whiteboardUseCase.createWhiteboard(nickname: nickname)
        whiteboardUseCase.startPublishingWhiteboard()
        whiteboardSubject.send(whiteboard)
    }
}
