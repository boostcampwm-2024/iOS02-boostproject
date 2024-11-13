//
//  ProfileIconView.swift
//  Presentation
//
//  Created by 최정인 on 11/12/24.
//

import Domain
import UIKit

final class ProfileIconView: UIView {
    private lazy var iconLabel: UILabel = {
        let label = UILabel()
        label.text = profileIcon.emoji
        label.font = .systemFont(ofSize: profileIconSize * 0.6)
        return label
    }()
    let profileIcon: ProfileIcon
    let profileIconSize: CGFloat

    init(profileIcon: ProfileIcon, profileIconSize: CGFloat) {
        self.profileIcon = profileIcon
        self.profileIconSize = profileIconSize
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        backgroundColor = UIColor(hex: profileIcon.colorHex)
        layer.cornerRadius = profileIconSize / 2
        clipsToBounds = true
    }

    private func configureLayout() {
        iconLabel.addToSuperview(self)
        iconLabel
            .center(in: self)
    }
}
