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

    public func save(
        dataInfo: DataInformationDTO,
        data: Data?,
        fileType: String? = nil
    ) -> URL? {
        guard let directoryURL = documentDirectoryURL?
            .appendingPathComponent(
                dataInfo
                    .type
                    .directoryName)
        else { return nil }

        createDirectory(at: directoryURL.path)

        return write(
            to: directoryURL,
            with: data,
            fileName: dataInfo.id.uuidString,
            fileType: fileType)
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
        fileName: String,
        fileType: String? = nil
    ) -> URL {
        let fileURL: URL

        if let fileType {
            fileURL = url.appendingPathComponent("\(fileName).\(fileType)")
        } else {
            fileURL = url.appendingPathComponent("\(fileName).json")
        }

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
