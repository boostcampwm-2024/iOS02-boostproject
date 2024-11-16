//
//  ManageWhiteboardObjectsUseCaseTests.swift
//  DomainTests
//
//  Created by 이동현 on 11/16/24.
//

import Combine
import Domain
import XCTest

final class ManageWhiteboardObjectsUseCaseTests: XCTestCase {
    private var useCase: ManageWhiteboardObjectUseCaseInterface!
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        useCase = ManageWhiteboardObjectUseCase()
        cancellables = []
    }

    override func tearDownWithError() throws {
        useCase = nil
    }

    // 화이트보드 위에 존재하는 오브젝트들 가져오기 성공 테스트
    func testFetchObjects() {
        // 준비
        let object1 = WhiteboardObject(
            id: UUID(),
            position: .zero,
            size: CGSize(width: 100, height: 100))
        let object2 = WhiteboardObject(
            id: UUID(),
            position: .zero,
            size: CGSize(width: 50, height: 50))
        let object3 = WhiteboardObject(
            id: UUID(),
            position: .zero,
            size: CGSize(width: 150, height: 150))

        // 실행
        _ = useCase.addObject(whiteboardObject: object1)
        _ = useCase.addObject(whiteboardObject: object2)
        _ = useCase.addObject(whiteboardObject: object3)
        let objects = useCase.fetchObjects()

        // 검증
        XCTAssertEqual(objects.count, 3)
        XCTAssertTrue(objects.contains(object1))
        XCTAssertTrue(objects.contains(object2))
        XCTAssertTrue(objects.contains(object3))
    }

    // 화이트보드 오브젝트 추가가 성공하는지 테스트
    func testAddWhiteboardObject() {
        // 준비
        let targetObject = WhiteboardObject(
            id: UUID(),
            position: .zero,
            size: CGSize(width: 100, height: 100))
        var receivedObject: WhiteboardObject?

        useCase.addedObjectPublisher
            .sink { object in
                receivedObject = object
            }
            .store(in: &cancellables)

        // 실행
        let result = useCase.addObject(whiteboardObject: targetObject)

        // 검증
        XCTAssertTrue(result)
        XCTAssertEqual(receivedObject, targetObject)
    }

    // 화이트보드 오브젝트 중복 추가가 실패하는지 테스트
    func testAddDuplicateObject() {
        // 준비
        let targetObject = WhiteboardObject(
            id: UUID(),
            position: .zero,
            size: CGSize(width: 100, height: 100))

        // 실행
        let isSuccess = useCase.addObject(whiteboardObject: targetObject)
        let isFailure = useCase.addObject(whiteboardObject: targetObject)

        // 검증
        XCTAssertTrue(isSuccess)
        XCTAssertFalse(isFailure)
        XCTAssertTrue(useCase.fetchObjects().count == 1)
    }

    // 화이트보드 오브젝트 업데이트 성공하는지 테스트
    func testUpdateObject() {
        // 준비
        let uuid = UUID()
        let object = WhiteboardObject(
            id: uuid,
            position: .zero,
            size: CGSize(width: 100, height: 100))
        let updatedObject = WhiteboardObject(
            id: uuid,
            position: CGPoint(x: 50, y: 50),
            size: CGSize(width: 200, height: 200))
        var receivedObject: WhiteboardObject?

        useCase.updatedObjectPublisher
            .sink { receivedObject = $0 }
            .store(in: &cancellables)

        // 실행
        _ = useCase.addObject(whiteboardObject: object)
        let result = useCase.updateObject(whiteboardObject: updatedObject)

        // 검증
        XCTAssertTrue(result)
        XCTAssertEqual(updatedObject, receivedObject)
    }

    // 화이트보드 오브젝트 삭제 성공하는지 테스트
    func testRemoveObject() {
        // 준비
        let object1 = WhiteboardObject(
            id: UUID(),
            position: .zero,
            size: CGSize(width: 100, height: 100))
        let object2 = WhiteboardObject(
            id: UUID(),
            position: .zero,
            size: CGSize(width: 100, height: 100))
        let targetObject = WhiteboardObject(
            id: UUID(),
            position: .zero,
            size: CGSize(width: 100, height: 100))
        var receivedObject: WhiteboardObject?

        useCase.removedObjectPublisher
            .sink { receivedObject = $0 }
            .store(in: &cancellables)

        // 실행
        _ = useCase.addObject(whiteboardObject: object1)
        _ = useCase.addObject(whiteboardObject: targetObject)
        _ = useCase.addObject(whiteboardObject: object2)
        let result = useCase.removeObject(whiteboardObject: targetObject)

        // 검증
        XCTAssertTrue(result)
        XCTAssertEqual(targetObject, receivedObject)
        XCTAssertTrue(useCase.fetchObjects().count == 2)
    }

    // 존재하지 않는 화이트보드 오브젝트 삭제 실패하는지 테스트
    func testRemoveNonExistentObject() {
        // 준비
        let object = WhiteboardObject(id: UUID(), position: .zero, size: CGSize(width: 100, height: 100))
        var receivedObject: WhiteboardObject?

        useCase.removedObjectPublisher
            .sink { receivedObject = $0 }
            .store(in: &cancellables)

        // 실행
        let result = useCase.removeObject(whiteboardObject: object)

        // 검증
        XCTAssertFalse(result)
        XCTAssertNil(receivedObject)
        XCTAssertEqual(useCase.fetchObjects().count, 0)
    }
}
