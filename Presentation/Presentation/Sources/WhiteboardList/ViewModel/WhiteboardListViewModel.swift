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
        case searchWhiteboard
        case stopSearchingWhiteboard
    }

    struct Output {
        let whiteboardPublisher: AnyPublisher<Whiteboard, Never>
        let whiteboardListPublisher: AnyPublisher<[Whiteboard], Never>
    }

    let output: Output
    private let whiteboardSubject: PassthroughSubject<Whiteboard, Never>
    private let whiteboardListSubject: CurrentValueSubject<[Whiteboard], Never>

    public init(whiteboardUseCase: WhiteboardUseCaseInterface) {
        self.whiteboardUseCase = whiteboardUseCase
        whiteboardSubject = PassthroughSubject<Whiteboard, Never>()
        whiteboardListSubject = CurrentValueSubject<[Whiteboard], Never>([])
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
        case .stopSearchingWhiteboard:
            stopSearchingWhiteboard()
        }
    }

    private func createWhiteboard() {
        let whiteboard = whiteboardUseCase.createWhiteboard()
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

    private func stopSearchingWhiteboard() {
        whiteboardUseCase.stopSearchingWhiteboard()
    }
}
