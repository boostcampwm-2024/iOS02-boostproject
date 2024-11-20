//
//  WhiteboardObject.swift
//  Domain
//
//  Created by 이동현 on 11/12/24.
//
import Foundation

public class WhiteboardObject: Equatable, Codable {
    public let id: UUID
    public var position: CGPoint
    public var size: CGSize

    public init(
        id: UUID,
        position: CGPoint,
        size: CGSize
    ) {
        self.id = id
        self.position = position
        self.size = size
    }

    public static func == (lhs: WhiteboardObject, rhs: WhiteboardObject) -> Bool {
        return lhs.id == rhs.id
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
