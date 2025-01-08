//
//  LWWRegister.swift
//  Domain
//
//  Created by 박승찬 on 1/6/25.
//

import Foundation

public struct LWWRegister {
    public let whiteboardObject: WhiteboardObject
    private let timestamp: Timestamp

    public init(whiteboardObject: WhiteboardObject, timestamp: Timestamp) {
        self.whiteboardObject = whiteboardObject
        self.timestamp = timestamp
    }

    public func merge(register: LWWRegister) -> LWWRegister {
        timestamp < register.timestamp ? register: self
    }
}

extension LWWRegister: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(whiteboardObject)
    }
}

extension LWWRegister: Comparable {
    public static func < (lhs: LWWRegister, rhs: LWWRegister) -> Bool {
        lhs.timestamp < rhs.timestamp
    }
}
