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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AirplainFont.Subtitle2
        label.textColor = .airplainBlack
        return label
    }()

    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()

    private let profileIconStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = -10
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
            .leading(equalTo: contentView.leadingAnchor, inset: 18)
            .centerY(equalTo: contentView.centerYAnchor)

        participantIcon.size(width: 15, height: 15)

        infoStackView.addArrangedSubview(participantIcon)
        infoStackView.addArrangedSubview(participantCountLabel)

        infoStackView
            .addToSuperview(contentView)
            .centerY(equalTo: contentView.centerYAnchor)
            .trailing(equalTo: contentView.trailingAnchor, inset: 18)

        profileIconStackView
            .addToSuperview(contentView)
            .centerY(equalTo: contentView.centerYAnchor)
            .trailing(equalTo: infoStackView.leadingAnchor, inset: 5)
            .height(equalTo: 20)
    }

    private func configureAttribute() {
        contentView.backgroundColor = .gray100
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }

    func configure(with board: Whiteboard) {
        titleLabel.text = board.name
        participantCountLabel.text = "\(board.participantIcons.count)/8"

        profileIconStackView
            .arrangedSubviews
            .forEach { $0.removeFromSuperview() }

        for (index, icon) in board.participantIcons.enumerated() {
            if index > 3 { break }

            let iconView = ProfileIconView()
            iconView.size(width: 20, height: 20)
            iconView.configure(profileIcon: icon, profileIconSize: 20)

            profileIconStackView.addArrangedSubview(iconView)
        }
    }
}
