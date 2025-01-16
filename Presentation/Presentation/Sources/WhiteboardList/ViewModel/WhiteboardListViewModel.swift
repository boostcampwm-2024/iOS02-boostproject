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
    private let whiteboardListUseCase: WhiteboardListUseCaseInterface
    private var cancellables = Set<AnyCancellable>()

    enum Input {
        case createWhiteboard
        case joinWhiteboard(whiteboard: Whiteboard)
        case startSearchingWhiteboards
    }

    struct Output {
        let whiteboardListPublisher: AnyPublisher<[Whiteboard], Never>
        let connectedWhiteboardPublisher: AnyPublisher<Whiteboard?, Never>
    }

    let output: Output
    private let connectedWhiteboardSubject: PassthroughSubject<Whiteboard?, Never>

    public init(whiteboardListUseCase: WhiteboardListUseCaseInterface) {
        self.whiteboardListUseCase = whiteboardListUseCase
        connectedWhiteboardSubject = PassthroughSubject<Whiteboard?, Never>()
        self.output = Output(
            whiteboardListPublisher: whiteboardListUseCase.whiteboardListPublisher,
            connectedWhiteboardPublisher: connectedWhiteboardSubject.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .createWhiteboard:
            createWhiteboard()
        case .joinWhiteboard(let whiteboard):
            joinWhiteboard(whiteboard: whiteboard)
        case .startSearchingWhiteboards:
            refreshWhiteboardList()
        }
    }

    private func createWhiteboard() {
        let whiteboard = whiteboardListUseCase.createWhiteboard()
        connectedWhiteboardSubject.send(whiteboard)
    }

    private func joinWhiteboard(whiteboard: Whiteboard) {
        Task {
            let whiteboard = await whiteboardListUseCase.joinWhiteboard(whiteboard: whiteboard)
            connectedWhiteboardSubject.send(whiteboard)
        }
    }

    private func refreshWhiteboardList() {
        whiteboardListUseCase.startSearchingWhiteboards()
    }
}
