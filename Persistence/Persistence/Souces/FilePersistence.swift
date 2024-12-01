//
//  FilePersistence.swift
//  Persistence
//
//  Created by 박승찬 on 11/20/24.
//

import DataSource
import Foundation
import OSLog

public struct FilePersistence: FilePersistenceInterface {
    private let fileManager = FileManager.default
    private var documentDirectoryURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    private let logger = Logger()

    public init() {}

    public func save(dataInfo: DataInformationDTO, data: Data?) -> URL? {
        guard let directoryURL = documentDirectoryURL?
            .appending(path: dataInfo
                .type
                .directoryName)
        else { return nil }

        createDirectory(at: directoryURL.path)

        return write(
            to: directoryURL,
            with: data,
            fileName: dataInfo.id.uuidString)
    }

    public func load(path: URL) -> Data? {
        var data: Data?

        do {
            data = try Data(contentsOf: path)
        } catch {
            logger.log("FilePersistence: 데이터 읽기 실패 \(path)")
        }

        return data
    }

    public func fetchURL(dataInfo: DataInformationDTO) -> URL? {
        guard let directoryURL = documentDirectoryURL?
            .appendingPathComponent(
                dataInfo
                    .type
                    .directoryName)
        else { return nil }

        let fileURL = directoryURL.appending(path: "\(dataInfo.id.uuidString)")

        if fileManager.fileExists(atPath: fileURL.path()) {
            return fileURL
        } else {
            return nil
        }
    }

    private func createDirectory(at path: String) {
        do {
            try fileManager.createDirectory(
                atPath: path,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            logger.log("FilePersistence: 디렉토리 생성 실패 \(path)")
        }
    }

    private func write(
        to url: URL,
        with data: Data?,
        fileName: String
    ) -> URL {
        let fileURL = url.appending(path: "\(fileName)")

        do {
            try data?.write(to: fileURL)
        } catch {
            logger.log("FilePersistence: 파일 생성 실패 \(fileURL)")
        }

        return fileURL
    }
}

fileprivate extension AirplaINDataType {
    var directoryName: String {
        switch self {
        case .text, .photo, .drawing, .game:
            return "whiteboardObject/\(rawValue)"
        default:
            return rawValue
        }
    }
}
