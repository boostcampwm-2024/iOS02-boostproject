//
//  ChatListCell.swift
//  Presentation
//
//  Created by 박승찬 on 11/26/24.
//

import Domain
import UIKit

class MessageCell: UICollectionViewListCell {
    enum MessageCellLayoutConstant {
        static let messageCornerRadius: CGFloat = 15
        static let messageViewPadding: CGFloat = 7
        static let messageMinWidth: CGFloat = 15
    }
    private var chatMessageCellModel: ChatMessageCellModel?

    func update(with newMessage: ChatMessageCellModel) {
        guard chatMessageCellModel != newMessage else { return }
        chatMessageCellModel = newMessage
        setNeedsUpdateConfiguration()
    }

    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.chatMessageCellModel = self.chatMessageCellModel
        return state
    }
}

fileprivate extension UIConfigurationStateCustomKey {
    static let chatMessageCellModel = UIConfigurationStateCustomKey("chatMessageCellModel")
}

extension UICellConfigurationState {
    var chatMessageCellModel: ChatMessageCellModel? {
        get { return self[.chatMessageCellModel] as? ChatMessageCellModel }
        set { self[.chatMessageCellModel] = newValue }
    }
}
