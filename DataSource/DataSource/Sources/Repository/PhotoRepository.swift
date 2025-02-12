//
//  PhotoRepository.swift
//  DataSource
//
//  Created by 이동현 on 11/26/24.
//

import Domain
import Foundation

public final class PhotoRepository: PhotoRepositoryInterface {
    private let filePersistence: FilePersistenceInterface

    public init(filePersistence: FilePersistenceInterface) {
        self.filePersistence = filePersistence
    }

    public func savePhoto(id: UUID, imageData: Data) -> URL? {
        let imageDTO = AirplaINDataDTO(
            id: id,
            data: imageData,
            type: .imageData,
            isDeleted: false)

        let imageURL = filePersistence.save(dto: imageDTO)
        return imageURL
    }

    public func fetchPhoto(id: UUID) -> Data? {
        let imageDTO = AirplaINDataDTO(
            id: id,
            data: Data(),
            type: .imageData,
            isDeleted: false)

        guard
            let imageURL = filePersistence.fetchURL(dto: imageDTO),
            let imageData = filePersistence.load(path: imageURL)
        else { return nil }

        return imageData
    }
}
