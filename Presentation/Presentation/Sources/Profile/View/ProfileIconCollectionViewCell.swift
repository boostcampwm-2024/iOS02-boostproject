//
//  ProfileIconCollectionViewCell.swift
//  Presentation
//
//  Created by 최정인 on 11/13/24.
//

import Domain
import UIKit

final class ProfileIconCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ProfileIconCollectionViewCell"
    private var profileIconView: ProfileIconView?

    func configure(profileIcon: ProfileIcon, profileIconSize: CGFloat) {
        profileIconView = ProfileIconView()
        guard let profileIconView else { return }
        profileIconView.configure(profileIcon: profileIcon, profileIconSize: profileIconSize)
        profileIconView.addToSuperview(contentView)
        profileIconView
            .center(in: contentView)
            .size(width: profileIconSize, height: profileIconSize)
    }
}
