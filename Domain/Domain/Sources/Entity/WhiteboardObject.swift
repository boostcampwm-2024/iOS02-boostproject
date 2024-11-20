//
//  WhiteboardObject.swift
//  Domain
//
//  Created by 이동현 on 11/12/24.
//
import Foundation

public class WhiteboardObject: Equatable {
    public let id: UUID
    public private(set) var position: CGPoint
    public private(set) var size: CGSize
    public private(set) var selectedBy: Profile?

    public init(
        id: UUID,
        position: CGPoint,
        size: CGSize,
        selectedBy: Profile?
    ) {
        self.id = id
        self.position = position
        self.size = size
        self.selectedBy = selectedBy
    }

    public static func == (lhs: WhiteboardObject, rhs: WhiteboardObject) -> Bool {
        return lhs.id == rhs.id
    }
}
