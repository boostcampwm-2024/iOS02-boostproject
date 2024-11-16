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
    private let currentDrawingImageView = UIImageView()
    private var imageRenderer: UIGraphicsImageRenderer?
    private var previousPoint: CGPoint?
    weak var delegate: DrawingViewDelegate?

    init() {
        super.init(frame: .zero)
        configureAttributes()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureAttributes()
        configureLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageRenderer = UIGraphicsImageRenderer(bounds: bounds)
    }

    private func configureAttributes() {
        let drawingGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrawingGesture(sender:)))
        drawingGesture.minimumNumberOfTouches = 1
        drawingGesture.maximumNumberOfTouches = 1
        self.addGestureRecognizer(drawingGesture)
    }

    private func configureLayout() {
        currentDrawingImageView
            .addToSuperview(self)
            .edges(equalTo: self)
    }

    @objc private func handleDrawingGesture(sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self)
        
        switch sender.state {
        case .began:
            delegate?.drawingViewDidStartDrawing(self, at: point)
            renderDrawing(at: point)
        case .changed:
            delegate?.drawingView(self, at: point)
            renderDrawing(at: point)
        case .ended:
            delegate?.drawingViewDidEndDrawing(self)
            previousPoint = nil
        default:
            break
        }
    }

    private func renderDrawing(at point: CGPoint) {

        let drawingImage: UIImage? = imageRenderer?.image { context in

            currentDrawingImageView
                .image?
                .draw(in: currentDrawingImageView.bounds)
            context.cgContext.setLineWidth(5)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)

            if let previousPoint {
                context.cgContext.move(to: previousPoint)
                context.cgContext.addLine(to: point)
                context.cgContext.strokePath()
            }
        }
        currentDrawingImageView.image = drawingImage
        previousPoint = point
    }
}
