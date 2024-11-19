//
//  ManageWhiteboardToolUseCaseInterface.swift
//  Domain
//
//  Created by 이동현 on 11/16/24.
//

import Combine

public protocol ManageWhiteboardToolUseCaseInterface {
    /// 화이트보드 도구 선택/선택 해제 시 이벤트를 방출합니다.
    var currentToolPublisher: AnyPublisher<WhiteboardTool?, Never> { get }

    /// 현재 사용중인 화이트보드 도구를 반환합니다.
    /// - Returns: 사용중인 화이트보드 도구
    func currentTool() -> WhiteboardTool?

    /// 화이트보드 도구를 선택합니다.
    /// - Parameter tool: 선택할 화이트보드 도구
    func selectTool(tool: WhiteboardTool)

    /// 화이트보드 도구 사용을 완료합니다.
    func finishUsingTool()
}
