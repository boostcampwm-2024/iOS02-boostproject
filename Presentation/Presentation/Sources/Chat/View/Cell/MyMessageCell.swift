//
//  MyMessageCell.swift
//  Presentation
//
//  Created by 박승찬 on 11/26/24.
//

import UIKit

final class MyMessageCell: MessageCell {
    enum MyMessageCellLayoutConstant {
        static let defaultTopPadding: CGFloat = 20
        static let betweenTopPadding: CGFloat = 11
    }

    private let messageView: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = AirplainFont.Body2
        label.numberOfLines = 0
        label.lineBreakStrategy = .standard

        return label
    }()

    private let messageBackground: UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .airplainBlue
        uiView.layer.cornerRadius = 15

        return uiView
    }()

    private var customViewConstraints: (
        labelWidth: NSLayoutConstraint,
        labelTrailing: NSLayoutConstraint,
        messageTopPadding: NSLayoutConstraint)?

    override func updateConfiguration(using state: UICellConfigurationState) {
        setupViewsIfNeeded()

        guard let chatMessageCellModel = state.chatMessageCellModel else { return }

        messageBackgroundConfigureLayout(chatMessageType: chatMessageCellModel.chatMessageType)
        cellHeightConfigureLayout(chatMessageType: chatMessageCellModel.chatMessageType)

        messageView.text = state.chatMessageCellModel?.chatMessage.message
    }

    private func setupViewsIfNeeded() {
        guard customViewConstraints == nil else { return }

        messageBackground
            .addToSuperview(contentView)

        messageView
            .addToSuperview(contentView)
            .bottom(equalTo: contentView.bottomAnchor, inset: 7)

        messageBackground
            .edges(equalTo: messageView, inset: -7)

        let constraints = (
            labelWidth: messageView
                .widthAnchor
                .constraint(lessThanOrEqualToConstant: contentView.frame.width * 3 / 4),
            labelTrailing: messageView
                .trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor, constant: -7),
            messageTopPadding: messageView
                .topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: MyMessageCellLayoutConstant.defaultTopPadding)
        )
        NSLayoutConstraint.activate([
            constraints.labelWidth,
            constraints.labelTrailing,
            constraints.messageTopPadding])
        customViewConstraints = constraints
    }

    private func messageBackgroundConfigureLayout(chatMessageType: ChatMessageType) {
        switch chatMessageType {
        case .first, .between:
            messageBackground.layer.maskedCorners = CACornerMask(
                arrayLiteral: .layerMinXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMinYCorner,
                .layerMaxXMaxYCorner)
        default:
            messageBackground.layer.maskedCorners = CACornerMask(
                arrayLiteral: .layerMinXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMinYCorner)
        }
    }

    private func cellHeightConfigureLayout(chatMessageType: ChatMessageType) {
        guard var topPaddingConstraint = customViewConstraints?.messageTopPadding else { return }
        NSLayoutConstraint.deactivate([
            topPaddingConstraint
        ])
        switch chatMessageType {
        case .single, .first:
            topPaddingConstraint = messageView
                .topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: MyMessageCellLayoutConstant.defaultTopPadding)
        case .between, .last:
            topPaddingConstraint = messageView
                .topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: MyMessageCellLayoutConstant.betweenTopPadding)
        }
        NSLayoutConstraint.activate([
            topPaddingConstraint
        ])
        customViewConstraints?.messageTopPadding = topPaddingConstraint
    }
}
