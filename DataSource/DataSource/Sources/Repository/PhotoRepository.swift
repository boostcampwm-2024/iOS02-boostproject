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
            type: .jpg,
            isDeleted: false)

        let photoURL = filePersistence.save(
            dataInfo: dataInformation,
            data: imageData,
            fileType: ".jpg")
        return photoURL
    }
}
