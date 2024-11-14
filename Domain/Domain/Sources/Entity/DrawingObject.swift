//
//  DrawingObject.swift
//  Domain
//
//  Created by 이동현 on 11/12/24.
//
import Foundation

public class DrawingObject: WhiteboardObject {
    public private(set) var points: [CGPoint]

    public init(
        id: UUID,
        position: CGPoint,
        size: CGSize,
        points: [CGPoint]
    ) {
        self.points = points
        super.init(
            id: id,
            position: position,
            size: size)
    }

    // TODO: - 화이트보드 오브젝트 수정 구현 시 고도화
    public func move(by translation: CGPoint) {
        points = points.map {
            let newOriginX = $0.x + translation.x
            let newOriginY = $0.y + translation.y
            return CGPoint(x: newOriginX, y: newOriginY)
        }
    }
}
