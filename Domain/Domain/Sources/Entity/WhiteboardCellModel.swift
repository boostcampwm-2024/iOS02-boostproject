//
//  WhiteboardCellModel.swift
//  Domain
//
//  Created by 최정인 on 11/19/24.
//

import Foundation

public struct WhiteboardCellModel: Hashable {
    public let id: UUID
    public let title: String
    public let icons: [ProfileIcon]

    public init(id: UUID, title: String, icons: [ProfileIcon]) {
        self.id = id
        self.title = title
        self.icons = icons
    }
}
