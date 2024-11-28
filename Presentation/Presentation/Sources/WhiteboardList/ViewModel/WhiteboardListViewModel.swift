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
        case joinWhiteboard(whiteboard: Whiteboard)
        case stopSearchingWhiteboard
        case refreshWhiteboardList
        case updateProfile
    }

    struct Output {
        let whiteboardListPublisher: AnyPublisher<[Whiteboard], Never>
    }

    let output: Output
    private let whiteboardSubject: PassthroughSubject<Whiteboard, Never>

    public init(whiteboardUseCase: WhiteboardUseCaseInterface) {
        self.whiteboardUseCase = whiteboardUseCase
        whiteboardSubject = PassthroughSubject<Whiteboard, Never>()
        self.output = Output(
            whiteboardListPublisher: whiteboardUseCase.whiteboardListPublisher)
    }

    func action(input: Input) {
        switch input {
        case .createWhiteboard:
            createWhiteboard()
        case .searchWhiteboard:
            searchWhiteboard()
        case .joinWhiteboard(let whiteboard):
            joinWhiteboard(whiteboard: whiteboard)
        case .stopSearchingWhiteboard:
            stopSearchingWhiteboard()
        case .refreshWhiteboardList:
            refreshWhiteboardList()
        case .updateProfile:
            updateProfile()
        }
    }

    private func createWhiteboard() {
        let whiteboard = whiteboardUseCase.createWhiteboard()
        whiteboardUseCase.startPublishingWhiteboard()
        whiteboardSubject.send(whiteboard)
    }

    private func searchWhiteboard() {
        whiteboardUseCase.startSearchingWhiteboard()
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
        whiteboardUseCase.refreshWhiteboardList()
    }

    private func updateProfile() {
        whiteboardUseCase.updateProfile()
    }
}
