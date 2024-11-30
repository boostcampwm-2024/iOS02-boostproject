//
//  RequestedContext.swift
//  DataSource
//
//  Created by 최다경 on 11/21/24.
//

import Foundation

public struct RequestedContext: Codable {
    let nickname: String
    let participant: String

    public init(nickname: String, participant: String) {
        self.nickname = nickname
        self.participant = participant
    }
}
