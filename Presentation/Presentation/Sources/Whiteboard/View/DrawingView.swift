//
//  DrawingView.swift
//  Presentation
//
//  Created by 이동현 on 11/16/24.
//

import UIKit

protocol DrawingViewDelegate: AnyObject {
    func drawingView(_ sender: DrawingView, at point: CGPoint)
    func drawingViewDidStartDrawing(_ sender: DrawingView, at point: CGPoint)
    func drawingViewDidEndDrawing(_ sender: DrawingView)
}

final class DrawingView: UIView {
    private let drawingLayer = CAShapeLayer()
    private let drawingPath = UIBezierPath()
    private var previousPoint: CGPoint?
    weak var delegate: DrawingViewDelegate?

    init() {
        super.init(frame: .zero)
        configureAttributes()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureAttributes()
    }

    func reset() {
        drawingLayer.path = nil
        drawingPath.removeAllPoints()
        previousPoint = nil
    }

    private func configureAttributes() {
        backgroundColor = .clear
        drawingLayer.strokeColor = UIColor.black.cgColor
        drawingLayer.lineWidth = 5
        drawingLayer.lineCap = .round
        layer.addSublayer(drawingLayer)

        let drawingGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrawingGesture(sender:)))
        drawingGesture.minimumNumberOfTouches = 1
        drawingGesture.maximumNumberOfTouches = 1
        self.addGestureRecognizer(drawingGesture)
    }

    @objc private func handleDrawingGesture(sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self)

        switch sender.state {
        case .began:
            previousPoint = point
            delegate?.drawingViewDidStartDrawing(self, at: point)
            drawLine(to: point)
        case .changed:
            delegate?.drawingView(self, at: point)
            drawLine(to: point)
        case .ended:
            delegate?.drawingViewDidEndDrawing(self)
            drawingLayer.path = nil
            previousPoint = nil
        default:
            break
        }
    }

    private func drawLine(to point: CGPoint) {
        guard let previousPoint else { return }

        drawingPath.move(to: previousPoint)
        drawingPath.addLine(to: point)
        drawingLayer.path = drawingPath.cgPath
        self.previousPoint = point
    }
}
