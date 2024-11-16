//
//  DrawingObjectView.swift
//  Presentation
//
//  Created by 이동현 on 11/16/24.
//

import Domain
import UIKit

final class DrawingObjectView: WhiteboardObjectView {
    let imageView = UIImageView()
    // TODO: - 딴과 논의 필요
    let objectId: UUID

    init(drawingObject: DrawingObject) {
        self.objectId = drawingObject.id
        super.init(whiteboardObject: drawingObject)

        configureLayout()
        renderImage(with: drawingObject)
    }

    required init?(coder: NSCoder) {
        objectId = UUID()
        super.init(coder: coder)
    }

    private func configureLayout() {
        imageView
            .addToSuperview(self)
            .edges(equalTo: self)
    }

    private func renderImage(with object: DrawingObject) {
        let renderer = DrawingRenderer()
        let renderedImage = renderer.render(drawingObject: object)
        imageView.image = renderedImage
    }
}
