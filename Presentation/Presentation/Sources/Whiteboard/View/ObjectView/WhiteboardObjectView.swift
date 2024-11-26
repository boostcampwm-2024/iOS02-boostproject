//
//  WhiteboardObjectView.swift
//  Presentation
//
//  Created by 이동현 on 11/12/24.
//
import Domain
import UIKit

public protocol WhiteboardObjectViewDelegate: AnyObject {
    func whiteboardObjectViewDidEndScaling(
        _ sender: WhiteboardObjectView,
        scale: CGFloat,
        angle: CGFloat)
    func whiteboardObjectViewDidEndMoving(_ sender: WhiteboardObjectView, newCenter: CGPoint)
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
    let objectID: UUID
    weak var delegate: WhiteboardObjectViewDelegate?
    private var initialControlAngle: CGFloat?

    init(whiteboardObject: WhiteboardObject) {
        objectID = whiteboardObject.id
        borderLayer = CALayer()
        super.init(frame: .zero)

        backgroundColor = .clear
        configureAttribute()
        configureLayout()
        update(with: whiteboardObject)
        configureEditable(isEditable: false)
    }

    required init?(coder: NSCoder) {
        objectID = UUID()
        borderLayer = CALayer()
        super.init(coder: coder)
        configureAttribute()
        configureLayout()
        configureEditable(isEditable: false)
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

        let moveGesture = UIPanGestureRecognizer(target: self, action: #selector(handleMoveObjectView))
        addGestureRecognizer(moveGesture)
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

    func configureEditable(isEditable: Bool) {
        controlView.isHidden = !isEditable
        gestureRecognizers?.forEach { $0.isEnabled = isEditable }
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
    }

    func update(with object: WhiteboardObject) {
        let center = object.centerPosition
        let bounds = CGRect(origin: .zero, size: object.size)

        self.center = center
        self.bounds = bounds

        applyTransform(scale: object.scale, angle: object.angle)

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
            let initialAngle = atan2(transform.b, transform.a)
            initialControlAngle = calculateAngle(controlPoint: controlPoint) - initialAngle
        case .changed:
            let scale = calculateScale(controlPoint: controlPoint)
            var angle = calculateAngle(controlPoint: controlPoint)
            angle = lockAngle(angle: angle)
            applyTransform(
                scale: scale,
                angle: angle)
        case .ended:
            let scale = calculateScale(controlPoint: controlPoint)
            var angle = calculateAngle(controlPoint: controlPoint)
            angle = lockAngle(angle: angle)
            delegate?.whiteboardObjectViewDidEndScaling(
                self,
                scale: scale,
                angle: angle)
            initialControlAngle = nil
        default:
            break
        }
    }

    private func calculateScale(controlPoint: CGPoint) -> CGFloat {
        let initialDistance = hypot(
            bounds.midX - bounds.maxX,
            bounds.midY - bounds.maxY)

        let distance = hypot(
            center.x - controlPoint.x,
            center.y - controlPoint.y)

        return distance / initialDistance
    }

    private func lockAngle(angle: CGFloat) -> CGFloat {
        let epsilon: CGFloat = 0.05
        let anglesToLock: [CGFloat] = [0, .pi / 2, .pi, -(.pi / 2), -(.pi)]

        for angleToLock in anglesToLock {
            let difference = abs(angle - angleToLock)
            if difference < epsilon { return angleToLock }
        }

        return angle
    }

    private func calculateAngle(controlPoint: CGPoint) -> CGFloat {
        let currentControlAngle = atan2(
            controlPoint.y - center.y,
            controlPoint.x - center.x)

        return currentControlAngle - (initialControlAngle ?? 0)
    }

    private func applyTransform(scale: CGFloat, angle: CGFloat) {
        CATransaction.setAnimationDuration(0)

        let inverseScale = 1 / scale
        let profileIconSize = WhiteboardObjectViewLayoutConstant.profileIconSize
        let profileIconViewOffset = (profileIconSize * scale - profileIconSize) / 2

        profileIconView.rotate(angle: -angle)
        profileIconView.transform = CGAffineTransform
            .identity
            .scaledBy(x: inverseScale, y: inverseScale)
            .translatedBy(x: profileIconViewOffset, y: profileIconViewOffset)
        controlView.transform = CGAffineTransform
            .identity
            .scaledBy(x: inverseScale, y: inverseScale)
        borderLayer.borderWidth = WhiteboardObjectViewLayoutConstant.selectorViewBorderWidth * inverseScale
        transform = CGAffineTransform
            .identity
            .scaledBy(x: scale, y: scale)
            .rotated(by: angle)
    }

    @objc private func handleMoveObjectView(gesture: UIPanGestureRecognizer) {

        let translation = gesture.translation(in: superview)
        let newCenter = CGPoint(
            x: center.x + translation.x,
            y: center.y + translation.y
        )

        switch gesture.state {
        case .possible, .began:
            break
        case .changed:
            center = newCenter
        default:
            delegate?.whiteboardObjectViewDidEndMoving(self, newCenter: newCenter)
        }

        gesture.setTranslation(.zero, in: superview)
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
