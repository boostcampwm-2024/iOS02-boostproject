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
    ///   - dto: 저장할 데이터
    /// - Returns: URL로 저장된 위치 반환
    @discardableResult
    func save(dto: AirplaINDataDTO) -> URL?

    /// path위치에 있는 데이터를 가져옵니다.
    /// - Parameter path: 가져올 데이터의 위치를 URL로 받습니다.
    /// - Returns: 해당 위치에 존재하는 데이터를 가져옵니다.
    func load(path: URL) -> Data?

    /// 데이터가 저장되어 있다면, 저장되어 있는 URL을 반환합니다.
    /// - Parameter dto: 저장한 데이터
    /// - Returns: 데이터의 저장 위치
    func fetchURL(dto: AirplaINDataDTO) -> URL?
}
