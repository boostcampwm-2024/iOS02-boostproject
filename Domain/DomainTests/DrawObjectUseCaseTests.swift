//
//  DrawObjectUseCaseTests.swift
//  DomainTests
//
//  Created by 이동현 on 11/13/24.
//
import Domain
import XCTest

final class DrawObjectUseCaseTests: XCTestCase {
    let lineWidth: CGFloat = 1
    var useCase: DrawObjectUseCaseInterface!

    override func setUpWithError() throws {
        useCase = DrawObjectUseCase()
        useCase.configureLineWidth(to: lineWidth)
    }

    override func tearDownWithError() throws {
        useCase = nil
    }

    // 그림을 그릴 때, points 배열에 점들을 올바르게 추가하는지 확인
    func testAddPointToArray() {
        // 준비
        let startPoint = CGPoint(x: 100, y: 100)
        let point1 = CGPoint(x: 115, y: 115)
        let point2 = CGPoint(x: 15, y: 30)

        // 실행
        useCase.startDrawing(at: startPoint)
        useCase.addPoint(point: point1)
        useCase.addPoint(point: point2)

        // 검증
        XCTAssertEqual(useCase.points, [startPoint, point1, point2])
    }

    // finishDrawing이 올바르게 DrawingObject를 생성하는지 확인
     func testFinishDrawingCreatesAndSendsDrawingObject() {
         // 준비
         let points: [CGPoint] = [
            CGPoint(x: 10, y: 10),
            CGPoint(x: 11, y: 11),
            CGPoint(x: 12, y: 12),
            CGPoint(x: 13, y: 13)
         ]
         useCase.startDrawing(at: points[0])
         points.dropFirst().forEach { useCase.addPoint(point: $0) }
         let padding = lineWidth / 2
         let expectedAdjustedPoints = [
             CGPoint(x: 0 + padding, y: 0 + padding),
             CGPoint(x: 1 + padding, y: 1 + padding),
             CGPoint(x: 2 + padding, y: 2 + padding),
             CGPoint(x: 3 + padding, y: 3 + padding)]
         let centerPoint = calculateMidPoint(from: points)

         // 실행
         let drawingObject = useCase.finishDrawing()

         // 검증
         XCTAssertNotNil(drawingObject)
         XCTAssertEqual(drawingObject?.centerPosition, centerPoint)
         XCTAssertEqual(drawingObject?.size, CGSize(width: 3 + padding * 2, height: 3 + padding * 2))
         XCTAssertEqual(drawingObject?.points, expectedAdjustedPoints)
     }

    // 그림 그린 후 useCase 내부 상태 초기화가 되는지 확인
    func testResetAfterFinishDrawing() {
        // 준비
        useCase.startDrawing(at: CGPoint(x: 10, y: 10))
        useCase.addPoint(point: CGPoint(x: 110, y: 110))
        useCase.addPoint(point: CGPoint(x: 120, y: 120))

        // 실행
        _ = useCase.finishDrawing()

        // 검증
        XCTAssertEqual(useCase.points.count, 0)
    }

    private func calculateMidPoint(from points: [CGPoint]) -> CGPoint {
        guard !points.isEmpty else { return .zero }

        let total = points.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y) }
        let count = CGFloat(points.count)
        return CGPoint(x: total.x / count, y: total.y / count)
    }
}
