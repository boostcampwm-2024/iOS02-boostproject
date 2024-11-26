//
//  PeerMessageCell.swift
//  Presentation
//
//  Created by 박승찬 on 11/26/24.
//

import UIKit

final class PeerMessageCell: MessageCell {
    private enum PeerMessageCellLayoutConstant {
        static let profileIconSize: CGFloat = 31
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
        label.lineBreakStrategy = .standard

        return label
    }()

    private let messageBackground: UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .gray200
        uiView.layer.cornerRadius = 15
        uiView.layer.maskedCorners = CACornerMask(
            arrayLiteral: .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner)

        return uiView
    }()

    private var customViewConstraints: (labelWidth: NSLayoutConstraint,
                                        labelLeading: NSLayoutConstraint)?

    override func updateConfiguration(using state: UICellConfigurationState) {
        setupViewsIfNeeded()

        guard let chatMessage = state.chatMessage else { return }
        messageView.text = chatMessage.message
        profileIconView.configure(
            profileIcon: chatMessage.sender.profileIcon,
            profileIconSize: PeerMessageCellLayoutConstant.profileIconSize)
        profileNameView.text = chatMessage.sender.nickname
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
            .bottom(equalTo: contentView.bottomAnchor, inset: 7)

        messageBackground
            .edges(equalTo: messageView, inset: -7)

        profileNameView
            .addToSuperview(contentView)
            .top(equalTo: contentView.topAnchor, inset: 17)
            .bottom(equalTo: messageBackground.topAnchor, inset: 8)
            .leading(equalTo: messageBackground.leadingAnchor, inset: 0)

        let constraints = (
            labelWidth: messageView
                .widthAnchor
                .constraint(lessThanOrEqualToConstant: contentView.frame.width * 3 / 4),
            labelLeading: messageView
                .leadingAnchor
                .constraint(equalTo: profileIconView.trailingAnchor, constant: 15))
        NSLayoutConstraint.activate([
            constraints.labelWidth,
            constraints.labelLeading])
        customViewConstraints = constraints
    }
}
