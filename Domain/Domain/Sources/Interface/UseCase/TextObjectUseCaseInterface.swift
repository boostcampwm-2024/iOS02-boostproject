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
    /// - Parameters:
    ///   - centerPoint: text오브젝트의 중심
    /// - Returns: 현재 화면 중앙에 위치한 TextObject를 반환
    func addText(centerPoint: CGPoint) -> TextObject

    /// TextObject의 text를 수정합니다.
    /// - Parameters:
    ///   - id: 수정할 TextObject의 아이디
    ///   - text: 수정할 text
    func editText(id: UUID, text: String) async
}
