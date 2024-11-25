//
//  DrawingObject.swift
//  Domain
//
//  Created by 이동현 on 11/12/24.
//
import Foundation

public final class DrawingObject: WhiteboardObject {
    public private(set) var points: [CGPoint]
    public let lineWidth: CGFloat

    private enum CodingKeys: String, CodingKey {
        case points
        case lineWidht
    }

    public init(
        id: UUID,
        centerPosition: CGPoint,
        size: CGSize,
        scale: CGFloat = 1,
        angle: CGFloat = 0,
        points: [CGPoint],
        lineWidth: CGFloat,
        selectedBy: Profile? = nil
    ) {
        self.points = points
        self.lineWidth = lineWidth
        super.init(
            id: id,
            centerPosition: centerPosition,
            size: size,
            scale: scale,
            angle: angle,
            selectedBy: selectedBy)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let points = try container.decode([CGPoint].self, forKey: .points)
        let lineWidth = try container.decode(CGFloat.self, forKey: .lineWidht)
        self.points = points
        self.lineWidth = lineWidth
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(points, forKey: .points)
        try container.encode(lineWidth, forKey: .lineWidht)
        try super.encode(to: encoder)
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
