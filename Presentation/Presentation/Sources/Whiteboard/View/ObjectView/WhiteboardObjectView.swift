//
//  WhiteboardObjectView.swift
//  Presentation
//
//  Created by 이동현 on 11/12/24.
//
import Domain
import UIKit

public protocol WhiteboardObjectViewDelegate: AnyObject {
    func whiteboardObjectViewDidStartPanning(_ sender: WhiteboardObjectView)
    func whiteboardObjectViewDidEndPanning(
        _ sender: WhiteboardObjectView,
        objectID: UUID,
        scale: CGFloat)
}

public class WhiteboardObjectView: UIView {
    private enum WhiteboardObjectViewLayoutConstant {
        static let profileIconSize: CGFloat = 30
        static let controlViewSize: CGFloat = 30
        static let controlViewInset: CGFloat = 5
        static let selectorViewBorderWidth: CGFloat = 3
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
    weak var delegate: WhiteboardObjectViewDelegate?

    init(whiteboardObject: WhiteboardObject) {
        objectId = whiteboardObject.id
        borderLayer = CALayer()
        super.init(frame: .zero)

        backgroundColor = .clear
        configureAttribute()
        configureLayout()
        update(with: whiteboardObject)
    }

    required init?(coder: NSCoder) {
        objectId = UUID()
        borderLayer = CALayer()
        super.init(coder: coder)
        configureAttribute()
        configureLayout()
    }

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let controlPoint = convert(point, to: controlView)
        if controlView.bounds.contains(controlPoint) {
            return controlView
        }

        return super.hitTest(point, with: event)
    }

    private func configureAttribute() {
        let controlPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleControlPanning))
        controlView.addGestureRecognizer(controlPanGesture)
    }

    func configureLayout() {
        profileIconView
            .addToSuperview(self)
            .centerX(
                equalTo: self.leadingAnchor,
                constant: -WhiteboardObjectViewLayoutConstant.controlViewSize / 2)
            .centerY(
                equalTo: self.topAnchor,
                constant: -WhiteboardObjectViewLayoutConstant.controlViewSize / 2)
            .size(
                width: WhiteboardObjectViewLayoutConstant.profileIconSize,
                height: WhiteboardObjectViewLayoutConstant.profileIconSize)

        controlView
            .addToSuperview(self)
            .centerX(equalTo: self.trailingAnchor)
            .centerY(equalTo: self.bottomAnchor)
            .size(
                width: WhiteboardObjectViewLayoutConstant.controlViewSize,
                height: WhiteboardObjectViewLayoutConstant.controlViewSize)

        controlImageView
            .addToSuperview(controlView)
            .edges(
                equalTo: controlView,
                inset: WhiteboardObjectViewLayoutConstant.controlViewInset)
    }

    func select(selector: Profile) {
        CATransaction.setAnimationDuration(0)

        layer.addSublayer(borderLayer)
        bringSubviewToFront(controlView)
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
    }

    func deselect() {
        CATransaction.setAnimationDuration(0)
        borderLayer.removeFromSuperlayer()
        profileIconView.isHidden = true
        controlView.isHidden = true
    }

    func update(with object: WhiteboardObject) {
        let center = object.centerPosition
        let bounds = CGRect(origin: .zero, size: object.size)

        self.center = center
        self.bounds = bounds

        applyScale(scale: object.scale)

        if let selector = object.selectedBy {
            select(selector: selector)
        } else {
            deselect()
        }
    }

    private func calculateBorderFrame() -> CGRect {
        let origin = CGPoint(x: 0, y: 0)
        let size = CGSize(
            width: bounds.width,
            height: bounds.height)

        return CGRect(origin: origin, size: size)
    }

    @objc private func handleControlPanning(_ gesture: UIPanGestureRecognizer) {
        let controlPoint = gesture.location(in: superview)
        switch gesture.state {
        case .began:
            delegate?.whiteboardObjectViewDidStartPanning(self)
        case .changed:
            guard let scale = calculateScale(controlPoint: controlPoint) else { return }
            applyScale(scale: scale)
        case .ended:
            guard let scale = calculateScale(controlPoint: controlPoint) else { return }
            delegate?.whiteboardObjectViewDidEndPanning(
                self,
                objectID: objectId,
                scale: scale)
        default:
            break
        }
    }

    private func calculateScale(controlPoint: CGPoint) -> CGFloat? {
        let initialDistance = hypot(
            bounds.midX - bounds.maxX,
            bounds.midY - bounds.maxY)

        let distance = hypot(
            center.x - controlPoint.x,
            center.y - controlPoint.y)

        return distance / initialDistance
    }

    private func applyScale(scale: CGFloat) {
        CATransaction.setAnimationDuration(0)

        let inverseScale = 1 / scale
        let profileIconSize = WhiteboardObjectViewLayoutConstant.profileIconSize
        let profileIconViewOffset = (profileIconSize * scale - profileIconSize) / 2

        transform = CGAffineTransform
            .identity
            .scaledBy(x: scale, y: scale)
        profileIconView.transform = CGAffineTransform
            .identity
            .scaledBy(x: inverseScale, y: inverseScale)
            .translatedBy(x: profileIconViewOffset, y: profileIconViewOffset)
        controlView.transform = CGAffineTransform
            .identity
            .scaledBy(x: inverseScale, y: inverseScale)
        borderLayer.borderWidth = WhiteboardObjectViewLayoutConstant.selectorViewBorderWidth * inverseScale
    }
}

// MARK: - WhiteboardViewController의 scrollView와 크기 조정 pangesture의 중복 작동을 막기 위한 UIGestureRecognizerDelegate
extension WhiteboardObjectView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return otherGestureRecognizer.view is UIScrollView
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return false
    }
}
