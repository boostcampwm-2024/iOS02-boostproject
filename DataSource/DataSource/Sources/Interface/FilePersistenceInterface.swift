//
//  FilePersistenceInterface.swift
//  DataSource
//
//  Created by 박승찬 on 11/20/24.
//

import Foundation

public protocol FilePersistenceInterface {
    /// 데이터를 dataInfo에 맞게 파일로 저장하고 저장위치를 반환합니다.
    /// - Parameters:
    ///   - dataInfo: 저장할 데이터의 정보: uuid, 데이터타입
    ///   - data: 저장할 데이터
    /// - Returns: URL로 저장된 위치 반환
    func save(dataInfo: DataInformationDTO, data: Data) -> URL?

    /// path위치에 있는 데이터를 가져옵니다.
    /// - Parameter path: 가져올 데이터의 위치를 URL로 받습니다.
    /// - Returns: 해당 위치에 존재하는 데이터를 가져옵니다.
    func load(path: URL) -> Data?
}
