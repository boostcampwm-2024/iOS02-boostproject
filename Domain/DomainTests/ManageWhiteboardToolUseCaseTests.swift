//
//  ManageWhiteboardToolUseCaseTests.swift
//  DomainTests
//
//  Created by 이동현 on 11/16/24.
//

import Combine
import Domain
import XCTest

final class ManageWhiteboardToolUseCaseTests: XCTestCase {
    private var useCase: WhiteboardToolUseCaseInterface!
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        useCase = WhiteboardToolUseCase()
        cancellables = []
    }

    override func tearDownWithError() throws {
        useCase = nil
    }

    // 선택한 도구가 없을 때 화이트보드 도구 선택 성공 테스트
    func testSelectTool() {
        // 준비
        let targetTool = WhiteboardTool.drawing
        var receivedTool: WhiteboardTool?

        // 실행
        useCase.currentToolPublisher
            .sink { receivedTool = $0 }
            .store(in: &cancellables)

        useCase.selectTool(tool: targetTool)

        // 검증
        XCTAssertEqual(targetTool, receivedTool)
        XCTAssertEqual(useCase.currentTool(), targetTool)
    }

    // 선택한 도구가 있을 때, 새로운 도구 선택 성공 테스트
    func testSelectToolOverridesPrevious() {
        // 준비
        let previousTool = WhiteboardTool.drawing
        let targetTool = WhiteboardTool.text
        var receivedTool: WhiteboardTool?

        useCase.currentToolPublisher
            .sink { receivedTool = $0 }
            .store(in: &cancellables)

        // 실행
        useCase.selectTool(tool: previousTool)
        useCase.selectTool(tool: targetTool)

        // 검증
        XCTAssertEqual(targetTool, receivedTool)
        XCTAssertEqual(useCase.currentTool(), targetTool)
    }

    // 화이트보드 도구 사용 완료 성공 테스트
    func testFinishUsingTool() {
        // 준비
        let tool = WhiteboardTool.drawing
        var receivedTool: WhiteboardTool?

        useCase.currentToolPublisher
            .sink { receivedTool = $0 }
            .store(in: &cancellables)

        // 실행
        useCase.selectTool(tool: tool)
        useCase.finishUsingTool()

        // 검증
        XCTAssertNil(receivedTool)
        XCTAssertNil(useCase.currentTool())
    }
}
