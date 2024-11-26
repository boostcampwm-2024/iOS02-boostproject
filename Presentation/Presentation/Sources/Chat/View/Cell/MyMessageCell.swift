//
//  MyMessageCell.swift
//  Presentation
//
//  Created by 박승찬 on 11/26/24.
//

import UIKit

final class MyMessageCell: MessageCell {
    private func defaultListContentConfiguration() -> UIListContentConfiguration { return .subtitleCell() }
    private lazy var listContentView = UIListContentView(configuration: defaultListContentConfiguration())

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
        uiView.layer.maskedCorners = CACornerMask(
            arrayLiteral: .layerMinXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMinYCorner)

        return uiView
    }()

    private var customViewConstraints: (labelWidth: NSLayoutConstraint,
                                        labelTrailing: NSLayoutConstraint)?

    override func updateConfiguration(using state: UICellConfigurationState) {
        setupViewsIfNeeded()

        messageView.text = state.chatMessage?.message
    }

    private func setupViewsIfNeeded() {
        guard customViewConstraints == nil else { return }

        messageBackground
            .addToSuperview(contentView)

        messageView
            .addToSuperview(contentView)
            .centerY(equalTo: contentView.centerYAnchor)

        messageBackground
            .edges(equalTo: messageView, inset: -7)

        let constraints = (
            labelWidth: messageView
                .widthAnchor
                .constraint(lessThanOrEqualToConstant: contentView.frame.width * 3 / 4),
            labelTrailing: messageView
                .trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor, constant: -7)
        )
        NSLayoutConstraint.activate([
            constraints.labelWidth,
            constraints.labelTrailing
        ])
        customViewConstraints = constraints
    }
}
