//
//  WhiteboardObjectView.swift
//  Presentation
//
//  Created by 이동현 on 11/12/24.
//
import Domain
import UIKit

public class WhiteboardObjectView: UIView {
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
    let objectId: UUID

    init(whiteboardObject: WhiteboardObject) {
        objectId = whiteboardObject.id
        let frame = CGRect(origin: whiteboardObject.position, size: whiteboardObject.size)
        super.init(frame: frame)
        backgroundColor = .clear
        configureLayout()
        if let selector = whiteboardObject.selectedBy {
            select(selector: selector)
        }
    }

    required init?(coder: NSCoder) {
        objectId = UUID()
        super.init(coder: coder)
        configureLayout()
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
        profileIconView.isHidden = false
    }

    func deselect() {
        profileIconView.isHidden = true
        layer.borderWidth = .zero
    }

    func update(with object: WhiteboardObject) {
        let origin = object.position
        let size = object.size
        frame = CGRect(origin: origin, size: size)

        if let selector = object.selectedBy {
            select(selector: selector)
        } else {
            deselect()
        }
    }
}
