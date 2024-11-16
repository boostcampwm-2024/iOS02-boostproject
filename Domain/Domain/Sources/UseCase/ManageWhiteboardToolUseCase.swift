//
//  ManageWhiteboardToolUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/16/24.
//

import Combine

public final class ManageWhiteboardToolUseCase: ManageWhiteboardToolUseCaseInterface {
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
        let previousTool = currentToolSubject.value
        if previousTool == tool {
            currentToolSubject.send(nil)
        } else {
            currentToolSubject.send(tool)
        }
    }

    public func finishUsingTool() {
        currentToolSubject.send(nil)
    }
}
