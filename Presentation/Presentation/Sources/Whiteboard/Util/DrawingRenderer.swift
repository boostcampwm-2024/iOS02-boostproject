//
//  DrawingRenderer.swift
//  Presentation
//
//  Created by 이동현 on 11/13/24.
//
import Domain
import UIKit

protocol DrawingRendererInterface {
    func render(drawingObject: DrawingObject) -> UIImage?
}

struct DrawingRenderer: DrawingRendererInterface {
    func render(drawingObject: DrawingObject) -> UIImage? {
        guard let startPoint = drawingObject.points.first else { return nil }

        let renderer = UIGraphicsImageRenderer(size: drawingObject.size)
        let image = renderer.image { context in
            context.cgContext.setLineWidth(5)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.move(to: startPoint)

            for point in drawingObject.points.dropFirst() {
                context.cgContext.addLine(to: point)
            }

            context.cgContext.strokePath()
        }
        return image
    }
}
