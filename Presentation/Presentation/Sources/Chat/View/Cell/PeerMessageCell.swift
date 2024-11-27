//
//  PeerMessageCell.swift
//  Presentation
//
//  Created by 박승찬 on 11/26/24.
//

import UIKit

final class PeerMessageCell: MessageCell {
    enum PeerMessageCellLayoutConstant {
        static let defaultTopPadding: CGFloat = 17
        static let betweenTopPadding: CGFloat = 11
        static let profileIconSize: CGFloat = 31
        static let profileIconTrailingPadding: CGFloat = 15
        static let profileNameBottomPadding: CGFloat = 8
    }

    private let profileIconView = ProfileIconView()
    private let profileNameView: UILabel = {
        let label = UILabel()
        label.textColor = .gray500
        label.font = AirplainFont.Body5

        return label
    }()

    private let messageView: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = AirplainFont.Body2
        label.numberOfLines = 0

        return label
    }()

    private let messageBackground: UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .gray200
        uiView.layer.cornerRadius = MessageCellLayoutConstant.messageCornerRadius

        return uiView
    }()

    private var customViewConstraints: (
        labelWidth: NSLayoutConstraint,
        labelLeading: NSLayoutConstraint,
        messageTopPadding: NSLayoutConstraint)?

    override func updateConfiguration(using state: UICellConfigurationState) {
        setupViewsIfNeeded()

        guard let chatMessageCellModel = state.chatMessageCellModel else { return }

        messageBackgroundConfigureLayout(chatMessageType: chatMessageCellModel.chatMessageType)
        cellHeightConfigureLayout(chatMessageType: chatMessageCellModel.chatMessageType)
        profileViewConfigureAttribute(chatMessageType: chatMessageCellModel.chatMessageType)

        messageView.text = chatMessageCellModel.chatMessage.message
        profileIconView.configure(
            profileIcon: chatMessageCellModel.chatMessage.sender.profileIcon,
            profileIconSize: PeerMessageCellLayoutConstant.profileIconSize)
        profileNameView.text = chatMessageCellModel.chatMessage.sender.nickname
    }

    private func setupViewsIfNeeded() {
        guard customViewConstraints == nil else { return }

        profileIconView
            .addToSuperview(contentView)
            .leading(equalTo: contentView.leadingAnchor, inset: 0)
            .bottom(equalTo: contentView.bottomAnchor, inset: 0)
            .size(
                width: PeerMessageCellLayoutConstant.profileIconSize,
                height: PeerMessageCellLayoutConstant.profileIconSize)

        messageBackground
            .addToSuperview(contentView)

        messageView
            .addToSuperview(contentView)
            .bottom(equalTo: contentView.bottomAnchor, inset: MessageCellLayoutConstant.messageViewPadding)

        messageBackground
            .edges(equalTo: messageView, inset: -MessageCellLayoutConstant.messageViewPadding)

        profileNameView
            .addToSuperview(contentView)
            .bottom(equalTo: messageBackground.topAnchor, inset: PeerMessageCellLayoutConstant.profileNameBottomPadding)
            .leading(equalTo: messageBackground.leadingAnchor, inset: 0)

        let constraints = (
            labelWidth: messageView
                .widthAnchor
                .constraint(lessThanOrEqualToConstant: contentView.frame.width * 3 / 4),
            labelLeading: messageView
                .leadingAnchor
                .constraint(
                    equalTo: profileIconView.trailingAnchor,
                    constant: PeerMessageCellLayoutConstant.profileIconTrailingPadding),
            messageTopPadding: profileNameView
                .topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: PeerMessageCellLayoutConstant.defaultTopPadding))
        NSLayoutConstraint.activate([
            constraints.labelWidth,
            constraints.labelLeading,
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
                .layerMaxXMinYCorner,
                .layerMaxXMaxYCorner)
        }
    }

    private func cellHeightConfigureLayout(chatMessageType: ChatMessageType) {
        guard var topPaddingConstraint = customViewConstraints?.messageTopPadding else { return }
        NSLayoutConstraint.deactivate([
            topPaddingConstraint
        ])
        switch chatMessageType {
        case .single, .first:
            topPaddingConstraint = profileNameView
                .topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: PeerMessageCellLayoutConstant.defaultTopPadding)
        case .between, .last:
            topPaddingConstraint = messageView
                .topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: PeerMessageCellLayoutConstant.betweenTopPadding)
        }
        NSLayoutConstraint.activate([
            topPaddingConstraint
        ])
        customViewConstraints?.messageTopPadding = topPaddingConstraint
    }

    private func profileViewConfigureAttribute(chatMessageType: ChatMessageType) {
        switch chatMessageType {
        case .single:
            profileIconView.isHidden = false
            profileNameView.isHidden = false
        case .first:
            profileIconView.isHidden = true
            profileNameView.isHidden = false
        case .between:
            profileIconView.isHidden = true
            profileNameView.isHidden = true
        case .last:
            profileIconView.isHidden = false
            profileNameView.isHidden = true
        }
    }
}
