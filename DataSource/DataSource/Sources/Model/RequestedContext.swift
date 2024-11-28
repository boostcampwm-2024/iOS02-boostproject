//
//  RequestedContext.swift
//  DataSource
//
//  Created by 최다경 on 11/21/24.
//

import Foundation

public struct RequestedContext: Codable {
    let participant: String
    let name: String

    public init(participant: String, name: String) {
        self.participant = participant
        self.name = name
    }
}
