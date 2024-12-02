//
//  PhotoRepositoryInterface.swift
//  Domain
//
//  Created by 이동현 on 11/26/24.
//

import Foundation

public protocol PhotoRepositoryInterface {
    /// 사진을 저장합니다
    /// - Parameter 
    ///  id: 사진의 id
    ///  imageData: 사진 이미지 데이터
    /// - Returns: 저장한 위치 URL
    @discardableResult
    func savePhoto(id: UUID, imageData: Data) -> URL?

    /// 저장된 사진을 가져옵니다
    /// - Parameter id: 사진의 id
    /// - Returns: 사진 데이터
    func fetchPhoto(id: UUID) -> Data?
}
