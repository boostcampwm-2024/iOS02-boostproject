//
//  WhiteboardObject.swift
//  Domain
//
//  Created by 이동현 on 11/12/24.
//
import Foundation

public class WhiteboardObject: Equatable, Codable {
    public let id: UUID
    public private(set) var centerPosition: CGPoint
    public private(set) var size: CGSize
    public private(set) var scale: CGFloat
    public private(set) var angle: CGFloat
    public private(set) var selectedBy: Profile?
    public private(set) var updatedAt: Date

    public init(
        id: UUID,
        centerPosition: CGPoint,
        size: CGSize,
        scale: CGFloat = 1,
        angle: CGFloat = 0,
        selectedBy: Profile? = nil
    ) {
        self.id = id
        self.centerPosition = centerPosition
        self.size = size
        self.scale = scale
        self.angle = angle
        self.selectedBy = selectedBy
        updatedAt = Date()
    }

    public static func == (lhs: WhiteboardObject, rhs: WhiteboardObject) -> Bool {
        return lhs.id == rhs.id
    }

    func select(by profile: Profile) {
        selectedBy = profile
        updatedAt = Date()
    }

    func deselect() {
        selectedBy = nil
        updatedAt = Date()
    }

    func changeScale(to scale: CGFloat) {
        self.scale = scale
    }

    func changePosition(position: CGPoint) {
        self.centerPosition = position
    }

    func changeAngle(to angle: CGFloat) {
        self.angle = angle
    }
}

extension WhiteboardObject: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension CGSize: Codable {
    private enum CodingKeys: String, CodingKey {
        case width
        case height
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.width, forKey: .width)
        try container.encode(self.height, forKey: .height)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let width = try container.decode(Double.self, forKey: .width)
        let height = try container.decode(Double.self, forKey: .height)
        self.init(width: width, height: height)
    }
}

extension CGPoint: Codable {
    private enum CodingKeys: String, CodingKey {
        case pointX
        case pointY
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.x, forKey: .pointX)
        try container.encode(self.y, forKey: .pointY)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let pointX = try container.decode(Double.self, forKey: .pointX)
        let pointY = try container.decode(Double.self, forKey: .pointY)
        self.init(x: pointX, y: pointY)
    }
}
