//
//  ChatUseCase.swift
//  Domain
//
//  Created by 박승찬 on 11/24/24.
//

import Combine

public final class ChatUseCase: ChatUseCaseInterface {
    public var chatMessagePublisher: AnyPublisher<ChatMessage, Never>
    private let chatMessageSubject: PassthroughSubject<ChatMessage, Never>
    private var chatRepository: ChatRepositoryInterface

    public init(chatRepository: ChatRepositoryInterface) {
        self.chatMessageSubject = PassthroughSubject<ChatMessage, Never>()
        self.chatMessagePublisher = chatMessageSubject.eraseToAnyPublisher()
        self.chatRepository = chatRepository
        self.chatRepository.delegate = self
    }

    public func send(message: String, profile: Profile) async -> Bool {
        guard let chatMessage = await chatRepository.send(message: message, profile: profile) else { return false }
        chatMessageSubject.send(chatMessage)

        return true
    }
}

extension ChatUseCase: ChatRepositoryDelegate {
    public func chatRepository(_ sender: ChatRepositoryInterface, didReceive chatMessage: ChatMessage) {
        chatMessageSubject.send(chatMessage)
    }
}
