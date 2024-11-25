//
//  ProfileIconView.swift
//  Presentation
//
//  Created by 최정인 on 11/12/24.
//

import Domain
import UIKit

final class ProfileIconView: UIView {
    private let iconLabel = UILabel()

    init() {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        clipsToBounds = true
    }

    private func configureLayout() {
        iconLabel.addToSuperview(self)
        iconLabel
            .center(in: self)
    }

    func configure(profileIcon: ProfileIcon, profileIconSize: CGFloat) {
        iconLabel.text = profileIcon.emoji
        iconLabel.font = .systemFont(ofSize: profileIconSize * 0.6)

        backgroundColor = UIColor(hex: profileIcon.colorHex)
        layer.cornerRadius = profileIconSize / 2
    }

    func rotate(angle: CGFloat) {
        iconLabel.transform = CGAffineTransform(rotationAngle: angle)
    }
}
