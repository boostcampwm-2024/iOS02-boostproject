//
//  AddPhotoUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/18/24.
//

import Foundation

public final class AddPhotoUseCase: AddPhotoUseCaseInterface {
    private let fileManager: FileManager
    private let photoDirectory: URL

    public init(fileManager: FileManager) throws {
        self.fileManager = fileManager
        guard
            let documentDirectory = fileManager
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first
        else { throw DomainError.cannotCreateDirectory }
        photoDirectory = documentDirectory.appending(path: "photos")

        if !fileManager.fileExists(atPath: photoDirectory.path()) {
            do {
                try fileManager.createDirectory(at: photoDirectory, withIntermediateDirectories: true)
            } catch {
                throw DomainError.cannotCreateDirectory
            }
        }
    }

    public func addPhoto(
        airplainImageData: AirplaINImageData,
        position: CGPoint
    ) throws -> PhotoObject {
        let uuid = UUID()
        let photoname = "\(uuid.uuidString).jpg"
        let photoURL = photoDirectory.appending(path: photoname)
        let imageSize = CGSize(width: airplainImageData.width, height: airplainImageData.height)

        do {
            try airplainImageData.imageData.write(to: photoURL)
        } catch {
            throw DomainError.cannotWriteFile
        }

        let photoObject = PhotoObject(
            id: uuid,
            position: position,
            size: imageSize,
            photoURL: photoURL)

        return photoObject
    }
}
