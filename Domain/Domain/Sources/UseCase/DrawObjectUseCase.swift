//
//  DrawObjectUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/13/24.
//

import Foundation

public final class DrawObjectUseCase: DrawObjectUseCaseInterface {
    public private(set) var points: [CGPoint]
    public private(set) var lineWidth: CGFloat

    public init() {
        points = []
        lineWidth = 5
    }

    public func configureLineWidth(to width: CGFloat) {
        lineWidth = width
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
        let padding = lineWidth / 2
        let origin = CGPoint(x: minX - padding, y: minY - padding)
        let size = CGSize(width: maxX - minX + padding * 2, height: maxY - minY + padding * 2)
        let adjustedPoints = points.map {
            CGPoint(x: $0.x - minX + padding, y: $0.y - minY + padding)
        }

        let drawingObject = DrawingObject(
            id: UUID(),
            position: origin,
            size: size,
            points: adjustedPoints,
            lineWidth: lineWidth)

        return drawingObject
    }

    private func reset() {
        points.removeAll()
    }
}
