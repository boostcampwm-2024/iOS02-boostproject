//
//  GameObjectUseCaseInterface.swift
//  Domain
//
//  Created by 최정인 on 11/27/24.
//

import Combine
import Foundation

public protocol GameObjectUseCaseInterface {
    /// Wordle 게임을 생성합니다.
    /// - Parameters:
    ///   - point: game 오브젝트의 중심
    /// - Returns: 생성된 GameObject
    func createGame(centerPoint point: CGPoint) -> GameObject
}
