//
//  TextObjectUseCaseTests.swift
//  DomainTests
//
//  Created by 박승찬 on 11/19/24.
//

import Domain
import XCTest

final class TextObjectUseCaseTests: XCTestCase {
    private var useCase: TextObjectUseCase!

    override func setUpWithError() throws {
        let mockCGSize = CGSize(width: 200, height: 50)
        useCase = TextObjectUseCase(whiteboardObjectSet: WhiteboardObjectSet(), textFieldDefaultSize: mockCGSize)
    }

    override func tearDownWithError() throws {
        useCase = nil
    }

    // addText테스트
    // 정상적인 입력
    func testAddText() {
        // 준비
        let expectedPosition = CGPoint(x: 100, y: 100)
        // 실행
        let createdTextObject = useCase.addText(centerPoint: expectedPosition)

        // 검증
        XCTAssertEqual(createdTextObject.centerPosition, expectedPosition)
    }

    // addText테스트
    // 입력(0)
    func testAddTextWithZeroPosition() {
        // 준비
        let textCenterPosition = CGPoint(x: 0, y: 0)
        let expectedPosition = CGPoint(x: 0, y: 0)

        // 실행
        let createdTextObject = useCase.addText(centerPoint: textCenterPosition)

        // 검증
        XCTAssertEqual(createdTextObject.centerPosition, expectedPosition)
    }

    // addText테스트
    // 비정상적인 입력(마이너스)
    func testAddTextWithMinusPosition() {
        // 준비
        let textCenterPosition = CGPoint(x: -100, y: -100)
        let expectedPosition = CGPoint(x: 0, y: 0)

        // 실행
        let createdTextObject = useCase.addText(centerPoint: textCenterPosition)

        // 검증
        XCTAssertEqual(createdTextObject.centerPosition, expectedPosition)
    }
}
