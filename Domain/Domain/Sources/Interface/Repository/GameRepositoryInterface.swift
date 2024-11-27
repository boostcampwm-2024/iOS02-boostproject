//
//  GameRepositoryInterface.swift
//  Domain
//
//  Created by 최정인 on 11/27/24.
//

public protocol GameRepositoryInterface {
    /// 랜덤한 게임 정답을 반환합니다.
    /// - Returns: 랜덤 게임 정답
    func randomGameAnswer() -> String

    /// 게임 정답 Set을 저장합니다.
    /// - Parameter wordleSet: 게임 정답 Set
    func saveWordleSet(wordleSet: [String])
}
