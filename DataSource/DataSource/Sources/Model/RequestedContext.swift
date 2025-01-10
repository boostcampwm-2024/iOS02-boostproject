//
//  RequestedContext.swift
//  DataSource
//
//  Created by 최다경 on 11/21/24.
//

import Foundation

public struct RequestedContext: Codable {
    public let peerID: UUID
    public let nickname: String
    public let participant: String

    public init(
        peerID: UUID,
        nickname: String,
        participant: String
    ) {
        self.peerID = peerID
        self.nickname = nickname
        self.participant = participant
    }
}
