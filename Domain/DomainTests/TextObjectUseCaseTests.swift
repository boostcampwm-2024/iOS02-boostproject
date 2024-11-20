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
        useCase = TextObjectUseCase(textFieldDefaultSize: mockCGSize)
    }

    override func tearDownWithError() throws {
        useCase = nil
    }

    // addText테스트
    // 정상적인 입력
    func testIdealAddText() {
        // 준비
        let testScrollViewOffset = CGPoint(x: 0, y: 0)
        let testViewSize = CGSize(width: 300, height: 300)
        let expectedPosition = CGPoint(
            x: testScrollViewOffset.x + testViewSize.width / 3,
            y: testScrollViewOffset.y + testViewSize.height / 3)

        // 실행
        let createdTextObject = useCase.addText(point: testScrollViewOffset, size: testViewSize)

        // 검증
        XCTAssertEqual(createdTextObject.position, expectedPosition)
    }

    // addText테스트
    // 비정상적인 입력(0)
    func testStrangeZeroAddText() {
        // 준비
        let testScrollViewOffset = CGPoint(x: 0, y: 0)
        let testViewSize = CGSize(width: 0, height: 0)
        let expectedPosition = CGPoint(
            x: testScrollViewOffset.x + testViewSize.width / 3,
            y: testScrollViewOffset.y + testViewSize.height / 3)

        // 실행
        let createdTextObject = useCase.addText(point: testScrollViewOffset, size: testViewSize)

        // 검증
        XCTAssertEqual(createdTextObject.position, expectedPosition)
    }

    // addText테스트
    // 비정상적인 입력(마이너스)
    func testStrangeMinusAddText() {
        // 준비
        let testScrollViewOffset = CGPoint(x: 0, y: 0)
        let testViewSize = CGSize(width: -300, height: -300)
        let expectedPosition = CGPoint(
            x: testScrollViewOffset.x + testViewSize.width / 3,
            y: testScrollViewOffset.y + testViewSize.height / 3)

        // 실행
        let createdTextObject = useCase.addText(point: testScrollViewOffset, size: testViewSize)

        // 검증
        XCTAssertEqual(createdTextObject.position, expectedPosition)
    }

}
