//
//  AddPhotoUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/18/24.
//

import Foundation

public final class PhotoUseCase: PhotoUseCaseInterface {
    private let photoRepository: PhotoRepositoryInterface

    public init(photoRepository: PhotoRepositoryInterface) {
        self.photoRepository = photoRepository
    }

    public func addPhoto(
        imageData: Data,
        centerPosition: CGPoint,
        size: CGSize
    ) -> PhotoObject? {
        let id = UUID()

        var size = size
        let scaleFactor = size.width >= size.height ? 200 / size.width : 200 / size.height
        size.width *= scaleFactor
        size.height *= scaleFactor

        let photoObject = PhotoObject(
            id: id,
            centerPosition: centerPosition,
            size: size)

        return photoObject
    }

    public func fetchPhoto(imageID: UUID) -> Data? {
        photoRepository.fetchPhoto(id: imageID)
    }
}
