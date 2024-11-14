//
//  PersistenceInterface.swift
//  DataSource
//
//  Created by 최정인 on 11/12/24.
//

import Foundation

public protocol PersistenceInterface {
    /// 영구 저장소에 데이터를 저장합니다.
    /// - Parameters:
    ///   - data: 저장할 데이터
    ///   - key: 데이터를 저장할 키 값
    func save<T: Codable>(data: T, forKey key: String)

    /// 영구 저장소에서 데이터를 꺼내옵니다.
    /// - Parameter key: 불러올 데이터의 키 값
    /// - Returns: 키에 해당하는 데이터를 반환, 데이터가 없거나 불러오지 못하는 경우 `nil` 값 반환
    func load<T: Codable>(forKey key: String) -> T?
}
