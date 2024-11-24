//
//  ChatRepositoryInterface.swift
//  Domain
//
//  Created by 박승찬 on 11/24/24.
//

public protocol ChatRepositoryInterface {
    /// ChatRepository의 delegate
    var delegate: ChatRepositoryDelegate? { get set }

    /// 주변 사람에게 채팅을 보내는 메소드
    /// - Parameter message: 전달할 메시지
    func send(message: String, profile: Profile) async -> ChatMessage?
}

public protocol ChatRepositoryDelegate: AnyObject {
    /// 채팅을 수신하면 실행 됩니다.
    /// - Parameters:
    ///   - sender: delegate 객체
    ///   - chatMessage: 수신받은 메시지
    func chatRepository(_ sender: ChatRepositoryInterface, didReceive chatMessage: ChatMessage)
}
