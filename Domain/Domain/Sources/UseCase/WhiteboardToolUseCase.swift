//
//  ManageWhiteboardToolUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/16/24.
//

import Combine

public final class WhiteboardToolUseCase: WhiteboardToolUseCaseInterface {
    public var currentToolPublisher: AnyPublisher<WhiteboardTool?, Never>
    private let currentToolSubject: CurrentValueSubject<WhiteboardTool?, Never>

    public init() {
        currentToolSubject = CurrentValueSubject<WhiteboardTool?, Never>(nil)
        currentToolPublisher = currentToolSubject.eraseToAnyPublisher()
    }

    public func currentTool() -> WhiteboardTool? {
        return currentToolSubject.value
    }

    public func selectTool(tool: WhiteboardTool) {
        let selectTool = currentToolSubject.value == tool ? nil: tool
        currentToolSubject.send(selectTool)
    }

    public func finishUsingTool() {
        currentToolSubject.send(nil)
    }
}
