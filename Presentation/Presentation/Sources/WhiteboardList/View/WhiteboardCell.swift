//
//  WhiteboardCell.swift
//  Presentation
//
//  Created by 최다경 on 11/19/24.
//

import Domain
import UIKit

class WhiteboardCell: UICollectionViewCell {
    static let reuseIdentifier = "WhiteboardCell"
    private enum WhiteboardCellLayoutConstant {
        static let infoStackViewSpacing: CGFloat = 5
        static let profileInfoStackViewSpacing: CGFloat = -10
        static let profileIconStackViewTrailingMargin: CGFloat = 5
        static let profileInfoStackViewHeight: CGFloat = 20
        static let profileIconSize: CGFloat = 20
        static let titleLabelLeadingMargin: CGFloat = 18
        static let participantIconSize: CGFloat = 15
        static let infoStackViewTrailingMargin: CGFloat = 18
        static let contentViewCornerRadius: CGFloat = 12
        static let contentViewShadowOpacity: Float = 0.3
        static let contentViewShadowOffset: CGSize = CGSize(width: 0, height: 2)
        static let contentViewShadowRadius: CGFloat = 4
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AirplainFont.Subtitle2
        label.textColor = .airplainBlack
        return label
    }()

    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = WhiteboardCellLayoutConstant.infoStackViewSpacing
        return stackView
    }()

    private let profileIconStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = WhiteboardCellLayoutConstant.profileInfoStackViewSpacing
        return stackView
    }()

    private let participantIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .gray700
        return imageView
    }()

    private let participantCountLabel: UILabel = {
        let label = UILabel()
        label.font = AirplainFont.Body4
        label.textColor = .gray700
        return label
    }()

    private let profileIcons = [ProfileIconView(), ProfileIconView(), ProfileIconView()]
    private let participantMaxCount = 8
    private let profileIconMaxCount = 3

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureAttribute()
        configureLayout()
    }

    private func configureLayout() {
        titleLabel
            .addToSuperview(contentView)
            .leading(
                equalTo: contentView.leadingAnchor,
                inset: WhiteboardCellLayoutConstant.titleLabelLeadingMargin)
            .centerY(equalTo: contentView.centerYAnchor)

        participantIcon.size(
            width: WhiteboardCellLayoutConstant.participantIconSize,
            height: WhiteboardCellLayoutConstant.participantIconSize)

        infoStackView.addArrangedSubview(participantIcon)
        infoStackView.addArrangedSubview(participantCountLabel)

        infoStackView
            .addToSuperview(contentView)
            .centerY(equalTo: contentView.centerYAnchor)
            .trailing(
                equalTo: contentView.trailingAnchor,
                inset: WhiteboardCellLayoutConstant.infoStackViewTrailingMargin)

        profileIconStackView
            .addToSuperview(contentView)
            .centerY(equalTo: contentView.centerYAnchor)
            .trailing(
                equalTo: infoStackView.leadingAnchor,
                inset: WhiteboardCellLayoutConstant.profileIconStackViewTrailingMargin)
            .height(equalTo: WhiteboardCellLayoutConstant.profileInfoStackViewHeight)

        profileIcons.forEach { icon in
            profileIconStackView.addArrangedSubview(icon)
            icon.size(
                width: WhiteboardCellLayoutConstant.profileIconSize,
                height: WhiteboardCellLayoutConstant.profileIconSize)
        }
    }

    private func configureAttribute() {
        contentView.backgroundColor = .gray100
        contentView.layer.cornerRadius = WhiteboardCellLayoutConstant.contentViewCornerRadius
        contentView.clipsToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = WhiteboardCellLayoutConstant.contentViewShadowOpacity
        layer.shadowOffset = WhiteboardCellLayoutConstant.contentViewShadowOffset
        layer.shadowRadius = WhiteboardCellLayoutConstant.contentViewShadowRadius
    }

    func configure(with board: Whiteboard) {
        titleLabel.text = "\(board.name)의 보드"
        participantCountLabel.text = "\(board.participantIcons.count)/\(participantMaxCount)"

        profileIcons.forEach { $0.isHidden = true }

        for (index, icon) in board.participantIcons.enumerated() {
            if index > profileIconMaxCount { break }
            profileIcons[index].isHidden = false
            profileIcons[index].configure(
                profileIcon: icon,
                profileIconSize: WhiteboardCellLayoutConstant.profileIconSize)
        }
    }
}
