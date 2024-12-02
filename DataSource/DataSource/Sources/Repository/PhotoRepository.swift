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
        let dataInformation = DataInformationDTO(
            id: id,
            type: .imageData,
            isDeleted: false)

        let imageURL = filePersistence.save(dataInfo: dataInformation, data: imageData)
        return imageURL
    }

    public func fetchPhoto(id: UUID) -> Data? {
        let dataInformation = DataInformationDTO(
            id: id,
            type: .imageData,
            isDeleted: false)

        guard
            let imageURL = filePersistence.fetchURL(dataInfo: dataInformation),
            let imageData = filePersistence.load(path: imageURL)
        else { return nil }

        return imageData
    }
}
