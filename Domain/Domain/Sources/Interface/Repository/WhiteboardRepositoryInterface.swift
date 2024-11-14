//
//  WhiteboardRepository.swift
//  Domain
//
//  Created by 최다경 on 11/12/24.
//

public protocol WhiteboardRepositoryInterface {
    /// 화이트보드를 생성합니다.
    /// - Parameter nickname: 유저 닉네임(화이트보드의 이름으로 사용)
    func createWhiteboard(nickname: String) -> Whiteboard

    /// 화이트보드를 주번에 알립니다.
    func startPublishing()
}
