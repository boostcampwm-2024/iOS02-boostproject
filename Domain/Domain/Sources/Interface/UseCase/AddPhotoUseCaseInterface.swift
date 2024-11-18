//
//  AddPhotoUseCaseInterface.swift
//  Domain
//
//  Created by 이동현 on 11/18/24.
//

import Foundation

public protocol AddPhotoUseCaseInterface {

    /// 사진 오브젝트를 추가합니다.
    /// - Parameters:
    ///   - imageData: 추가할 사진의 데이터
    ///   - position: 사진을 추가할 위치 (origin)
    ///   - size: 사진 객체
    /// - Returns:
    func addPhoto(
        imageData: Data,
        position: CGPoint,
        size: CGSize
    ) throws -> PhotoObject
}
