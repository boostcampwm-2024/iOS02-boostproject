//
//  RequestedContext.swift
//  DataSource
//
//  Created by 최다경 on 11/21/24.
//

import Foundation

public struct RequestedContext: Codable {
    let participant: String

    public init(participant: String) {
        self.participant = participant
    }
}
