//
//  Timestamp.swift
//  Domain
//
//  Created by 박승찬 on 1/6/25.
//

import Foundation

public struct Timestamp: Comparable {
    let updatedAt: Date
    let updatedBy: UUID

    public init(updatedAt: Date, updatedBy: UUID) {
        self.updatedAt = updatedAt
        self.updatedBy = updatedBy
    }

    public static func < (lhs: Timestamp, rhs: Timestamp) -> Bool {
        if lhs.updatedAt == rhs.updatedAt { return lhs.updatedBy < rhs.updatedBy }
        return lhs.updatedAt < rhs.updatedAt
    }
}
