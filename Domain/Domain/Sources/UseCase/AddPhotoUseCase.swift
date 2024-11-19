//
//  AddPhotoUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/18/24.
//

import Foundation

public final class AddPhotoUseCase: AddPhotoUseCaseInterface {
    private let photoDirectory: URL
    private let fileManager: FileManager

    public init() throws {
        fileManager = FileManager.default
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
        imageData: Data,
        position: CGPoint,
        size: CGSize
    ) throws -> PhotoObject {
        let uuid = UUID()
        let photoname = "\(uuid.uuidString).jpg"
        let photoURL = photoDirectory.appending(path: photoname)

        do {
            try imageData.write(to: photoURL)
        } catch {
            throw DomainError.cannotWriteFile
        }

        let photoObject = PhotoObject(
            id: uuid,
            position: position,
            size: size,
            photoURL: photoURL)

        return photoObject
    }
}
