//
//  DrawObjectUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/13/24.
//

import Foundation

public final class DrawObjectUseCase: DrawObjectUseCaseInterface {
    public private(set) var points: [CGPoint]
//    public private(set) var origin: CGPoint?

    public init() {
        points = []
    }

    public func startDrawing(at point: CGPoint) {
        points = [point]
    }

    public func addPoint(point: CGPoint) {
        points.append(point)
    }

    public func finishDrawing() -> DrawingObject? {
        defer { reset() }
        let (xPoints, yPoints) = points.reduce(into: ([CGFloat](), [CGFloat]())) {
            $0.0.append($1.x)
            $0.1.append($1.y)
        }

        guard
            let minX = xPoints.min(),
            let maxX = xPoints.max(),
            let minY = yPoints.min(),
            let maxY = yPoints.max()
        else { return nil }

        let origin = CGPoint(x: minX, y: minY)
        let size = CGSize(width: maxX - minX, height: maxY - minY)
        let adjustedPoints = points.map {
            CGPoint(x: $0.x - minX, y: $0.y - minY)
        }

        let drawingObject = DrawingObject(
            id: UUID(),
            position: origin,
            size: size,
            points: adjustedPoints)

        return drawingObject
    }

    private func reset() {
        points.removeAll()
    }
}
