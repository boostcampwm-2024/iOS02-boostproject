//
//  ChatMessage.swift
//  Domain
//
//  Created by 박승찬 on 11/24/24.
//

import Foundation

public struct ChatMessage: Codable {
    public let message: String
    public let sender: Profile
    public let sentAt: Date

    public init(
        message: String,
        sender: Profile,
        sentAt: Date = Date()
    ) {
        self.message = message
        self.sender = sender
        self.sentAt = sentAt
    }
}
