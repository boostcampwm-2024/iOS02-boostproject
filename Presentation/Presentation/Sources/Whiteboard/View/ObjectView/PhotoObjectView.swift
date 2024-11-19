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
    let objectId: UUID

    init(photoObject: PhotoObject) {
        self.objectId = photoObject.id
        var width = photoObject.size.width
        var height = photoObject.size.height
        let scaleFactor: CGFloat = width >= height ? 200 / width : 200 / height
        width *= scaleFactor
        height *= scaleFactor

        let imageViewFrame = CGRect(
            x: photoObject.position.x - width / 2,
            y: photoObject.position.y - height / 2,
            width: width,
            height: height)
        super.init(frame: imageViewFrame)

        configureAttribute()
        configureLayout()
        configureImage(with: photoObject)
    }

    required init?(coder: NSCoder) {
        objectId = UUID()
        super.init(coder: coder)
    }

    private func configureAttribute() {
        imageView.contentMode = .scaleAspectFit
    }

    private func configureLayout() {
        imageView
            .addToSuperview(self)
            .edges(equalTo: self)
    }

    private func configureImage(with object: PhotoObject) {
        guard
            let imageData = try? Data(contentsOf: object.photoURL),
            let image = UIImage(data: imageData)
        else { return }

        imageView.image = image
    }
}
