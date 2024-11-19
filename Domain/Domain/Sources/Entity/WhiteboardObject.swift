//
//  WhiteboardObject.swift
//  Domain
//
//  Created by 이동현 on 11/12/24.
//
import Foundation

public class WhiteboardObject: Equatable {
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
