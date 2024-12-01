//
//  PhotoObjectView.swift
//  Presentation
//
//  Created by 이동현 on 11/18/24.
//

import Domain
import UIKit

public protocol PhotoObjectViewDelegate: AnyObject {
    func photoObjectViewWillConfigurePhoto(_ sender: PhotoObjectView)
}

public final class PhotoObjectView: WhiteboardObjectView {
    let imageView = UIImageView()
    weak var photoObjectDelegate: PhotoObjectViewDelegate?

    init(photoObject: PhotoObject, photoObjectDelegate: PhotoObjectViewDelegate?) {
        super.init(whiteboardObject: photoObject)
        self.photoObjectDelegate = photoObjectDelegate

        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func configureAttribute() {
        imageView.contentMode = .scaleAspectFit
        self.photoObjectDelegate?.photoObjectViewWillConfigurePhoto(self)
    }

    override func configureLayout() {
        imageView
            .addToSuperview(self)
            .edges(equalTo: self)
        super.configureLayout()
    }

    override func update(with object: WhiteboardObject) {
        super.update(with: object)
        photoObjectDelegate?.photoObjectViewWillConfigurePhoto(self)
    }

    func configureImage(imageData: Data) {
        imageView.image = UIImage(data: imageData)
    }
}
