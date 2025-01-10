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

    override func deepCopy() -> WhiteboardObject {
        return DrawingObject(
            id: id,
            centerPosition: centerPosition,
            size: size,
            scale: scale,
            angle: angle,
            points: points,
            lineWidth: lineWidth,
            selectedBy: selectedBy)
    }
}
