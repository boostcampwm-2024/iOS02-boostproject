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
        let whiteboardSubject: PassthroughSubject<Whiteboard, Never>
    }

    var output: Output

    public init(whiteboardUseCase: WhiteboardUseCaseInterface, nickname: String) {
        self.whiteboardUseCase = whiteboardUseCase
        self.nickname = nickname
        self.output = Output(whiteboardSubject: PassthroughSubject<Whiteboard, Never>())
    }

    func action(input: Input) {
        switch input {
        case .createWhiteboard:
            createWhiteboard()
        }
    }

    private func createWhiteboard() {
        let whiteboard = whiteboardUseCase.createWhiteboard(nickname: nickname)
        whiteboardUseCase.startPublishing()
        output.whiteboardSubject.send(whiteboard)
    }
}
