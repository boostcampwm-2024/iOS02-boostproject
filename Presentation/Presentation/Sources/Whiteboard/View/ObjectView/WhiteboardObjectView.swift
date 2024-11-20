//
//  WhiteboardObjectView.swift
//  Presentation
//
//  Created by 이동현 on 11/12/24.
//
import Domain
import UIKit

class WhiteboardObjectView: UIView {
    private enum WhiteboardObjectViewLayoutConstant {
        static let profileIconSize: CGFloat = 30
        static let selectorViewBorderWidth: CGFloat = 5
    }

    private let profileIconView: ProfileIconView = {
        let profileIconView = ProfileIconView()
        profileIconView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner
        ]
        return profileIconView
    }()

    init(whiteboardObject: WhiteboardObject) {
        let frame = CGRect(origin: whiteboardObject.position, size: whiteboardObject.size)
        super.init(frame: frame)
        configureLayout()
        if let selector = whiteboardObject.selectedBy {
            select(selector: selector)
        }
    }

    init(whiteboardObject: WhiteboardObject, frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        if let selector = whiteboardObject.selectedBy {
            select(selector: selector)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayout()
    }

    private func initialize() {

    }

    private func configureLayout() {
        profileIconView
            .addToSuperview(self)
            .trailing(equalTo: self.leadingAnchor, inset: .zero)
            .bottom(equalTo: self.topAnchor, inset: .zero)
            .size(
                width: WhiteboardObjectViewLayoutConstant.profileIconSize,
                height: WhiteboardObjectViewLayoutConstant.profileIconSize)
    }

    func select(selector: Profile) {
        let profileIcon = selector.profileIcon
        let colorHex = profileIcon.colorHex
        let profileColor = UIColor(hex: colorHex)
        layer.borderWidth = WhiteboardObjectViewLayoutConstant.selectorViewBorderWidth
        layer.borderColor = profileColor.cgColor
        profileIconView.configure(
            profileIcon: profileIcon,
            profileIconSize: WhiteboardObjectViewLayoutConstant.profileIconSize)
    }

    func deselect() {
        profileIconView.isHidden = true
        layer.borderWidth = .zero
    }
}
