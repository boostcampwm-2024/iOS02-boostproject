//
//  WhiteboardCellModel.swift
//  Presentation
//
//  Created by 최다경 on 11/19/24.
//

import Foundation
import Domain

struct WhiteboardCellModel: Hashable {
    let id: UUID
    let title: String
    let icons: [ProfileIcon]
}
