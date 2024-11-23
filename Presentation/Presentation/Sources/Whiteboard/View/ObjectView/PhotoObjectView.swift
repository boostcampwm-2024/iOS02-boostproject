//
//  PhotoObjectView.swift
//  Presentation
//
//  Created by 이동현 on 11/18/24.
//

import Domain
import UIKit

final class PhotoObjectView: WhiteboardObjectView {
    let imageView = UIImageView()

    init(photoObject: PhotoObject) {
        super.init(whiteboardObject: photoObject)
        configureFrame(photoObject: photoObject)
        configureAttribute()
        configureLayout()
        configureImage(with: photoObject)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func update(with whiteboardObject: WhiteboardObject) {
        guard let photoObject = whiteboardObject as? PhotoObject else { return }
        configureFrame(photoObject: photoObject)

        if let selector = photoObject.selectedBy {
            select(selector: selector)
        } else {
            deselect()
        }
    }

    private func configureAttribute() {
        imageView.contentMode = .scaleAspectFit
    }

    override func configureLayout() {
        imageView
            .addToSuperview(self)
            .edges(equalTo: self)
        super.configureLayout()
    }

    private func configureFrame(photoObject: PhotoObject) {
        var width = photoObject.size.width
        var height = photoObject.size.height
        let scaleFactor: CGFloat = width >= height ? 200 / width : 200 / height
        width *= scaleFactor
        height *= scaleFactor

        let frame = CGRect(
            x: photoObject.position.x - width / 2,
            y: photoObject.position.y - height / 2,
            width: width,
            height: height)
        self.frame = frame
    }

    private func configureImage(with object: PhotoObject) {
        guard
            let imageData = try? Data(contentsOf: object.photoURL),
            let image = UIImage(data: imageData)
        else { return }

        imageView.image = image
    }
}
