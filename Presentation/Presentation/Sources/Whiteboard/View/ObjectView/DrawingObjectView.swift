//
//  DrawingObjectView.swift
//  Presentation
//
//  Created by 이동현 on 11/16/24.
//

import Domain
import UIKit

final class DrawingObjectView: WhiteboardObjectView {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .airplainBlack
        return imageView
    }()

    init(drawingObject: DrawingObject) {
        super.init(whiteboardObject: drawingObject)

        configureLayout()
        renderImage(with: drawingObject)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func configureLayout() {
        imageView
            .addToSuperview(self)
            .edges(equalTo: self)
        super.configureLayout()
    }

    private func renderImage(with object: DrawingObject) {
        let renderer = DrawingRenderer()
        let renderedImage = renderer.render(drawingObject: object)

        imageView.image = renderedImage
    }
}
