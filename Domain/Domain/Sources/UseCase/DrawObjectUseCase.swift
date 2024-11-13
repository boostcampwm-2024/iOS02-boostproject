//
//  DrawObjectUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/13/24.
//

import Foundation

final class DrawObjectUseCase: DrawObjectUseCaseInterface {
    private var drawingObject: DrawingObject?
    private let repository: WhiteboardObjectRepositoryInterface
    private var points: [CGPoint]
    private var origin: CGPoint?
    private var minPoint: CGPoint?
    
    init(repository: WhiteboardObjectRepositoryInterface) {
        self.repository = repository
        points = []
    }
    
    func startDrawing(at point: CGPoint) {
        origin = point
    }
    
    func addPoint(point: CGPoint) {
        points.append(point)
    }
    
    func finishDrawing() -> DrawingObject? {
        defer { reset() }
        let (xPoints, yPoints) = points.reduce(into: ([CGFloat](), [CGFloat]())) {
            $0.0.append($1.x)
            $0.1.append($1.y)
        }
        
        guard
            let origin,
            let minX = xPoints.min(),
            let maxX = xPoints.max(),
            let minY = yPoints.min(),
            let maxY = yPoints.max()
        else { return nil }
        
        let size = CGSize(width: maxX - minX, height: maxY - minY)
        let adjustedPoints = points.map {
            CGPoint(x: $0.x - minX, y: $0.y - minY)
        }
        
        drawingObject = DrawingObject(
            id: UUID(),
            position: origin,
            size: size,
            points: adjustedPoints)

        guard let drawingObject else { return nil }
        repository.send(whiteboardObject: drawingObject)
        return drawingObject
    }
    
    private func reset() {
        drawingObject = nil
        minPoint = nil
        origin = nil
        points.removeAll()
    }
}
