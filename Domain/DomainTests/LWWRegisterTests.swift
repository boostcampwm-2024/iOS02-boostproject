//
//  LWWRegisterTests.swift
//  DomainTests
//
//  Created by 박승찬 on 1/8/25.
//

import Domain
import XCTest

final class LWWRegisterTests: XCTestCase {
    private var register: LWWRegister!
    private var defaultTimestamp: Timestamp!
    private var defaultDate: Date!
    private var defaultObject: WhiteboardObject!

    override func setUp() {
        super.setUp()
        defaultObject = TextObject(
            id: UUID(),
            centerPosition: CGPoint(x: 0, y: 0),
            size: CGSize(width: 100, height: 100),
            text: "default")
        defaultDate = Date()
        defaultTimestamp = Timestamp(updatedAt: defaultDate, updatedBy: UUID())
        register = LWWRegister(whiteboardObject: defaultObject, timestamp: defaultTimestamp)
    }

    override func tearDown() {
        register = nil
        defaultTimestamp = nil
        defaultDate = nil
        defaultObject = nil
    }

    // Timestamp가 같을 때
    func testMergeWhenEqualTimestmap() {
        // 준비
        let textObject = TextObject(
            id: UUID(),
            centerPosition: CGPoint(x: 50, y: 50),
            size: CGSize(width: 200, height: 200),
            text: "equal")
        let mockRegister = LWWRegister(whiteboardObject: textObject, timestamp: defaultTimestamp)

        // 실행
        let sut = register.merge(register: mockRegister)

        // 검증
        XCTAssertEqual(sut, register)
    }

    // 새로 들어온 updatedAt이 더 빠를 때
    func testMergeWhenIncomingTimestampIsEarlier() {
        // 준비
        let earlierDate = defaultDate.addingTimeInterval(-10)
        let earlierTimestamp = Timestamp(updatedAt: earlierDate, updatedBy: UUID())
        let textObject = TextObject(
            id: UUID(),
            centerPosition: CGPoint(x: 50, y: 50),
            size: CGSize(width: 200, height: 200),
            text: "incoming")
        let mockRegister = LWWRegister(whiteboardObject: textObject, timestamp: earlierTimestamp)

        // 실행
        let sut = register.merge(register: mockRegister)

        // 검증
        XCTAssertEqual(sut, register)
    }

    // updatedAt은 같지만 새로 들어온 UUID가 작을 때
    func testMergeWhenIncomingTimestampHasSmallerUUID() {
        // 준비
        guard let smallerUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000") else {
            XCTFail("Test UUID생성 실패")
            return
        }
        let smallerTimestamp = Timestamp(updatedAt: defaultDate, updatedBy: smallerUUID)
        let textObject = TextObject(
            id: UUID(),
            centerPosition: CGPoint(x: 50, y: 50),
            size: CGSize(width: 200, height: 200),
            text: "incoming")
        let mockRegister = LWWRegister(whiteboardObject: textObject, timestamp: smallerTimestamp)

        // 실행
        let sut = register.merge(register: mockRegister)

        // 검증
        XCTAssertEqual(sut, register)
    }

    // 새로 들어온 updatedAt이 더 느릴 때
    func testMergeWhenIncomingTimestampIsLater() {
        // 준비
        let laterDate = defaultDate.addingTimeInterval(10)
        let laterTimestamp = Timestamp(updatedAt: laterDate, updatedBy: UUID())
        let textObject = TextObject(
            id: UUID(),
            centerPosition: CGPoint(x: 50, y: 50),
            size: CGSize(width: 200, height: 200),
            text: "incoming")
        let mockRegister = LWWRegister(whiteboardObject: textObject, timestamp: laterTimestamp)

        // 실행
        let sut = register.merge(register: mockRegister)

        // 검증
        XCTAssertEqual(sut, mockRegister)
    }

    // updatedAt은 같지만 새로 들어온 UUID가 클 때
    func testMergeWhenIncomingTimestampHasLargerUUID() {
        // 준비
        guard let largerUUID = UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF") else {
            XCTFail("Test UUID생성 실패")
            return
        }
        let largerTimestamp = Timestamp(updatedAt: defaultDate, updatedBy: largerUUID)
        let textObject = TextObject(
            id: UUID(),
            centerPosition: CGPoint(x: 50, y: 50),
            size: CGSize(width: 200, height: 200),
            text: "incoming")
        let mockRegister = LWWRegister(whiteboardObject: textObject, timestamp: largerTimestamp)

        // 실행
        let sut = register.merge(register: mockRegister)

        // 검증
        XCTAssertEqual(sut, mockRegister)
    }
}
