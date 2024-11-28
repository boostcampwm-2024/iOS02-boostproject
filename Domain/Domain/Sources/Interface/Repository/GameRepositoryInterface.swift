//
//  GameRepositoryInterface.swift
//  Domain
//
//  Created by 최정인 on 11/27/24.
//

import Foundation

public protocol GameRepositoryInterface {
    /// 랜덤한 게임 정답을 반환합니다.
    /// - Returns: 랜덤 게임 정답
    func randomGameAnswer() -> String

    /// 게임 정답 Set을 저장합니다.
    /// - Parameter wordleAnswerSet: 게임 정답 Set
    func saveWordleAnswerSet(wordleAnswerSet: [String])

    /// 저장된 게임 기록을 불러옵니다.
    /// - Parameter gameID: 게임 기록을 불러올 게임 ID
    /// - Returns: 게임 History
    func loadWordleHistory(gameID: UUID) -> [String]

    /// 게임 기록을 저장합니다.
    /// - Parameters:
    ///   - gameID: 기록을 저장할 게임 ID
    ///   - wordleHistory: 게임 History
    func saveWordleHistory(gameID: UUID, wordleHistory: [String])
}
