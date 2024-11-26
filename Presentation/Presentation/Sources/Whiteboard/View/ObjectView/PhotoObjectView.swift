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
        configureAttribute()
        configureLayout()
        configureImage(with: photoObject.photoURL)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
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

    private func configureImage(with imageURL: URL) {
        guard
            let imageData = try? Data(contentsOf: imageURL),
            let image = UIImage(data: imageData)
        else { return }

        imageView.image = image
    }
}
