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
    private var cancellables = Set<AnyCancellable>()

    enum Input {
        case createWhiteboard
        case searchWhiteboard
    }

    struct Output {
        let whiteboardPublisher: AnyPublisher<Whiteboard, Never>
        let whiteboardListPublisher: AnyPublisher<[WhiteboardCellModel], Never>
    }

    let output: Output
    private let whiteboardSubject: PassthroughSubject<Whiteboard, Never>
    private let whiteboardListSubject: CurrentValueSubject<[WhiteboardCellModel], Never>

    public init(whiteboardUseCase: WhiteboardUseCaseInterface, nickname: String) {
        self.whiteboardUseCase = whiteboardUseCase
        self.nickname = nickname
        whiteboardSubject = PassthroughSubject<Whiteboard, Never>()
        whiteboardListSubject = CurrentValueSubject<[WhiteboardCellModel], Never>([])
        self.output = Output(
            whiteboardPublisher: whiteboardSubject.eraseToAnyPublisher(),
            whiteboardListPublisher: whiteboardListSubject.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .createWhiteboard:
            createWhiteboard()
        case .searchWhiteboard:
            searchWhiteboard()
        }
    }

    private func createWhiteboard() {
        let whiteboard = whiteboardUseCase.createWhiteboard(nickname: nickname)
        whiteboardUseCase.startPublishingWhiteboard()
        whiteboardSubject.send(whiteboard)
    }

    private func searchWhiteboard() {
        whiteboardUseCase.startSearchingWhiteboard()
        bindWhiteboards()
    }

    private func bindWhiteboards() {
        whiteboardUseCase.whiteboardListPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] whiteboards in
                self?.whiteboardListSubject.send(whiteboards)
            }
            .store(in: &cancellables)
    }
}
