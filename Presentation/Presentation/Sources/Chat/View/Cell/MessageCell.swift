//
//  ChatListCell.swift
//  Presentation
//
//  Created by 박승찬 on 11/26/24.
//

import Domain
import UIKit

class MessageCell: UICollectionViewListCell {
    private var chatMessage: ChatMessage?

    func update(with newMessage: ChatMessage) {
        guard chatMessage != newMessage else { return }
        chatMessage = newMessage
        setNeedsUpdateConfiguration()
    }

    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.chatMessage = self.chatMessage
        return state
    }
}

fileprivate extension UIConfigurationStateCustomKey {
    static let chatMessage = UIConfigurationStateCustomKey("chatMessage")
}

extension UICellConfigurationState {
    var chatMessage: ChatMessage? {
        get { return self[.chatMessage] as? ChatMessage }
        set { self[.chatMessage] = newValue }
    }
}
