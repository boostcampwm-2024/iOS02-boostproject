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
    private var cancellables = Set<AnyCancellable>()

    enum Input {
        case createWhiteboard
        case joinWhiteboard(whiteboard: Whiteboard)
        case stopSearchingWhiteboard
        case startSearchingWhiteboards
        case disconnectWhiteboard
    }

    struct Output {
        let whiteboardListPublisher: AnyPublisher<[Whiteboard], Never>
        let connectionStatusPublisher: AnyPublisher<Bool, Never>
    }

    let output: Output
    private let whiteboardSubject: PassthroughSubject<Whiteboard, Never>
    private let connectionStatusSubject: PassthroughSubject<Bool, Never>

    public init(whiteboardUseCase: WhiteboardUseCaseInterface) {
        self.whiteboardUseCase = whiteboardUseCase
        whiteboardSubject = PassthroughSubject<Whiteboard, Never>()
        connectionStatusSubject = PassthroughSubject<Bool, Never>()
        self.output = Output(
            whiteboardListPublisher: whiteboardUseCase.whiteboardListPublisher,
            connectionStatusPublisher: connectionStatusSubject.eraseToAnyPublisher()
        )
        bindWhiteboardConnectionResult()
    }

    func action(input: Input) {
        switch input {
        case .createWhiteboard:
            createWhiteboard()
        case .joinWhiteboard(let whiteboard):
            joinWhiteboard(whiteboard: whiteboard)
        case .stopSearchingWhiteboard:
            stopSearchingWhiteboard()
        case .startSearchingWhiteboards:
            refreshWhiteboardList()
        case .disconnectWhiteboard:
            disconnectWhiteboard()
        }
    }

    private func createWhiteboard() {
        let whiteboard = whiteboardUseCase.createWhiteboard()
        whiteboardUseCase.startPublishingWhiteboard()
        whiteboardSubject.send(whiteboard)
    }

    private func joinWhiteboard(whiteboard: Whiteboard) {
        do {
            try whiteboardUseCase.joinWhiteboard(whiteboard: whiteboard)
        } catch {
            // TODO: Alert 창 띄우기
        }
    }

    private func stopSearchingWhiteboard() {
        whiteboardUseCase.stopSearchingWhiteboard()
    }

    private func refreshWhiteboardList() {
        whiteboardUseCase.startSearchingWhiteboards()
    }

    private func disconnectWhiteboard() {
        whiteboardUseCase.disconnectWhiteboard()
    }

    private func bindWhiteboardConnectionResult() {
        whiteboardUseCase.whiteboardConnectionPublisher
            .sink { [weak self] isConnected in
                self?.connectionStatusSubject.send(isConnected)
            }
            .store(in: &cancellables)
    }

}
