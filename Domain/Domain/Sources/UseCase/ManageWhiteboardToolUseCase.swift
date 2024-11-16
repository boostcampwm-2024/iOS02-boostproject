//
//  ManageWhiteboardToolUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/16/24.
//

import Combine

final class ManageWhiteboardToolUseCase: ManageWhiteboardToolUseCaseInterface {
    var currentToolPublisher: AnyPublisher<WhiteboardTool?, Never>
    private let currentToolSubject: CurrentValueSubject<WhiteboardTool?, Never>

    init() {
        currentToolSubject = CurrentValueSubject<WhiteboardTool?, Never>(nil)
        currentToolPublisher = currentToolSubject.eraseToAnyPublisher()
    }

    func currentTool() -> WhiteboardTool? {
        return currentToolSubject.value
    }

    func selectTool(tool: WhiteboardTool) {
        currentToolSubject.send(tool)
    }

    func finishUsingTool() {
        currentToolSubject.send(nil)
    }
}
