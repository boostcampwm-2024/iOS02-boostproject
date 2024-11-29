//
//  ChatMessageModel.swift
//  Presentation
//
//  Created by 박승찬 on 11/26/24.
//

import Domain
import Foundation

struct ChatMessageCellModel: Hashable {
    let id: UUID
    let chatMessage: ChatMessage
    let chatMessageType: ChatMessageType

    init(
        id: UUID = UUID(),
        chatMessage: ChatMessage,
        chatMessageType: ChatMessageType
    ) {
        self.id = id
        self.chatMessage = chatMessage
        self.chatMessageType = chatMessageType
    }
}

enum ChatMessageType {
    case single
    case first
    case between
    case last
}
