//
//  AddPhotoUseCaseInterface.swift
//  Domain
//
//  Created by 이동현 on 11/18/24.
//

import Foundation

public protocol PhotoUseCaseInterface {
    /// 사진 오브젝트를 추가합니다.
    /// - Parameters:
    ///   - imageData: 추가할 사진의 데이터
    ///   - centerPosition: 사진의 중심
    ///   - size: 사진의 크기
    /// - Returns: 사진 객체
    func addPhoto(
        imageData: Data,
        centerPosition: CGPoint,
        size: CGSize
    ) -> PhotoObject?

    /// 사진을 가져옵니다.
    /// - Parameter imageID: 가져올 사진 id
    /// - Returns: 사진 바이너리 데이터
    func fetchPhoto(imageID: UUID) -> Data?
}
