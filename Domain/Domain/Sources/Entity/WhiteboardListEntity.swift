//
//  WhiteboardListEntity.swift
//  Domain
//
//  Created by 최정인 on 11/19/24.
//

import Foundation

public struct WhiteboardListEntity {
    public let id: UUID
    public let name: String
    public var info: [String]

    public init(id: UUID, name: String, info: [String]) {
        self.id = id
        self.name = name
        self.info = info
    }
}
