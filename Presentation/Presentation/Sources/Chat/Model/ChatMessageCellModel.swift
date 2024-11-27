//
//  ChatMessageModel.swift
//  Presentation
//
//  Created by 박승찬 on 11/26/24.
//

import Domain

struct ChatMessageCellModel: Hashable {
    let chatMessage: ChatMessage
    let chatMessageType: ChatMessageType
}

enum ChatMessageType {
    case single
    case first
    case between
    case last
}
