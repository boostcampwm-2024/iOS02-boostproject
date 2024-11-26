//
//  ChatUseCaseInterface.swift
//  Domain
//
//  Created by 박승찬 on 11/24/24.
//

import Combine

public protocol ChatUseCaseInterface {
    /// 채팅이 추가됐을 경우 ChatMessage를 방출하는 퍼블리셔
    var chatMessagePublisher: AnyPublisher<ChatMessage, Never> { get }

    /// 채팅을 전송하는 메서드
    /// - Parameters:
    ///   - message: 전송하는 메시지
    ///   - profile: 전송자의 프로필
    /// - Returns: 성공의 결과를 return (전송실패를 처리하기위한 값)
    func send(message: String, profile: Profile) async -> Bool
}
