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
        static let controlViewSize: CGFloat = 30
        static let controlViewInset: CGFloat = 5
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

    private let controlView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = WhiteboardObjectViewLayoutConstant.controlViewSize / 2
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.airplainBlack.cgColor
        view.backgroundColor = .airplainWhite
        view.isHidden = true
        return view
    }()

    private let controlImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "arrow.up.left.and.arrow.down.right")
        imageView.tintColor = .airplainBlack
        return imageView
    }()

    private let borderLayer: CALayer
    let objectId: UUID

    init(whiteboardObject: WhiteboardObject) {
        objectId = whiteboardObject.id
        let frame = CGRect(origin: whiteboardObject.position, size: whiteboardObject.size)
        borderLayer = CALayer()
        super.init(frame: frame)
        backgroundColor = .clear
        configureBorderLayer()
        configureLayout()
        if let selector = whiteboardObject.selectedBy {
            select(selector: selector)
        }
    }

    required init?(coder: NSCoder) {
        objectId = UUID()
        borderLayer = CALayer()
        super.init(coder: coder)
        configureBorderLayer()
        configureLayout()
    }

    func configureLayout() {
        profileIconView
            .addToSuperview(self)
            .trailing(equalTo: leadingAnchor, inset: .zero)
            .bottom(equalTo: topAnchor, inset: .zero)
            .size(
                width: WhiteboardObjectViewLayoutConstant.profileIconSize,
                height: WhiteboardObjectViewLayoutConstant.profileIconSize)

        controlView
            .addToSuperview(self)
            .leading(
                equalTo: trailingAnchor,
                constant: -WhiteboardObjectViewLayoutConstant.controlViewSize / 2)
            .top(
                equalTo: bottomAnchor,
                constant: -WhiteboardObjectViewLayoutConstant.controlViewSize / 2)
            .size(
                width: WhiteboardObjectViewLayoutConstant.controlViewSize,
                height: WhiteboardObjectViewLayoutConstant.controlViewSize)

        controlImageView
            .addToSuperview(controlView)
            .edges(
                equalTo: controlView,
                inset: WhiteboardObjectViewLayoutConstant.controlViewInset)
    }

    private func configureBorderLayer() {
        borderLayer.borderWidth = WhiteboardObjectViewLayoutConstant.selectorViewBorderWidth
        layer.addSublayer(borderLayer)
    }

    func select(selector: Profile) {
        CATransaction.setAnimationDuration(0)
        let profileIcon = selector.profileIcon
        let colorHex = profileIcon.colorHex
        let profileColor = UIColor(hex: colorHex)
        profileIconView.configure(
            profileIcon: profileIcon,
            profileIconSize: WhiteboardObjectViewLayoutConstant.profileIconSize)
        profileIconView.isHidden = false
        controlView.isHidden = false
        borderLayer.frame = calculateBorderFrame()
        borderLayer.borderColor = profileColor.cgColor
        borderLayer.isHidden = false
    }

    func deselect() {
        CATransaction.setAnimationDuration(0)
        profileIconView.isHidden = true
        controlView.isHidden = true
        borderLayer.isHidden = true
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

    private func calculateBorderFrame() -> CGRect {
        let origin = CGPoint(
            x: .zero - WhiteboardObjectViewLayoutConstant.selectorViewBorderWidth,
            y: .zero - WhiteboardObjectViewLayoutConstant.selectorViewBorderWidth)
        let size = CGSize(
            width: bounds.width + WhiteboardObjectViewLayoutConstant.selectorViewBorderWidth * 2,
            height: bounds.height + WhiteboardObjectViewLayoutConstant.selectorViewBorderWidth * 2)

        return CGRect(origin: origin, size: size)
    }
}
