//
//  DrawObjectUseCaseTests.swift
//  DomainTests
//
//  Created by 이동현 on 11/13/24.
//
import Domain
import XCTest

final class DrawObjectUseCaseTests: XCTestCase {
    var useCase: DrawObjectUseCaseInterface!
    var mockRepository: WhiteboardObjectRepositoryInterface!

    override func setUpWithError() throws {
        mockRepository = MockWhiteboardObjectRepository()
        useCase = DrawObjectUseCase(repository: mockRepository)
    }

    override func tearDownWithError() throws {
        mockRepository = nil
        useCase = nil
    }

    // startDrawing시, 시작 좌표를 올바르게 설정하는지 확인
    func testStartDrawingSetsOrigin() {
        let startPoint = CGPoint(x: 100, y: 100)
        useCase.startDrawing(at: startPoint)

        XCTAssertEqual(startPoint, useCase.origin)
    }

    // 그림을 그릴 때, points 배열에 점들을 올바르게 추가하는지 확인
    func testAddPointToArray() {
        let startPoint = CGPoint(x: 100, y: 100)
        let point1 = CGPoint(x: 115, y: 115)
        let point2 = CGPoint(x: 15, y: 30)
        
        useCase.startDrawing(at: startPoint)
        useCase.addPoint(point: point1)
        useCase.addPoint(point: point2)

        XCTAssertEqual(useCase.points, [startPoint, point1, point2])
    }

    // finishDrawing이 올바르게 DrawingObject를 생성하는지 확인
     func testFinishDrawingCreatesAndSendsDrawingObject() {
         useCase.startDrawing(at: CGPoint(x: 10, y: 10))
         useCase.addPoint(point: CGPoint(x: 11, y: 11))
         useCase.addPoint(point: CGPoint(x: 12, y: 12))
         useCase.addPoint(point: CGPoint(x: 13, y: 13))
         
         let drawingObject = useCase.finishDrawing()
         
         XCTAssertNotNil(drawingObject)
         XCTAssertEqual(drawingObject?.position, CGPoint(x: 10, y: 10))
         XCTAssertEqual(drawingObject?.size, CGSize(width: 3, height: 3))
         
         let expectedAdjustedPoints = [
             CGPoint(x: 0, y: 0),
             CGPoint(x: 1, y: 1),
             CGPoint(x: 2, y: 2),
             CGPoint(x: 3, y: 3)]
         XCTAssertEqual(drawingObject?.points, expectedAdjustedPoints)
     }
    
    // 그림 그린 후 useCase 내부 상태 초기화가 되는지 확인
    func testResetAfterFinishDrawing() {
        useCase.startDrawing(at: CGPoint(x: 10, y: 10))
        useCase.addPoint(point: CGPoint(x: 110, y: 110))
        useCase.addPoint(point: CGPoint(x: 120, y: 120))
        _ = useCase.finishDrawing()

        XCTAssertNil(useCase.origin)
        XCTAssertEqual(useCase.points.count, 0)
    }
}

final class MockWhiteboardObjectRepository: WhiteboardObjectRepositoryInterface {
    private var continuation: AsyncStream<WhiteboardObject>.Continuation?

    func send(whiteboardObject: WhiteboardObject) {
        continuation?.yield(whiteboardObject)
    }

    func whiteboardObjectAsyncStream() -> AsyncStream<WhiteboardObject> {
        return AsyncStream { continuation in
            self.continuation = continuation
        }
    }
}
