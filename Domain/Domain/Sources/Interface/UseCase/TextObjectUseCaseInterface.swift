//
//  TextObjectUseCaseInterface.swift
//  Domain
//
//  Created by 박승찬 on 11/18/24.
//

import Combine
import Foundation

public protocol TextObjectUseCaseInterface {
    /// TextObject를 생성하고 반환합니다.
    /// 현재 화면 중앙에 위치할 수 있도록 조절합니다.
    /// - Parameters:
    ///   - centerPoint: text오브젝트의 중심
    ///   - size: 현재 뷰의 크기
    /// - Returns: 현재 화면 중앙에 위치한 TextObject를 반환
    func addText(centerPoint: CGPoint, size: CGSize) -> TextObject
}
