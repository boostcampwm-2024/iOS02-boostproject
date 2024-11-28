//
//  ChatViewModel.swift
//  Presentation
//
//  Created by 박승찬 on 11/26/24.
//

import Combine
import Domain

public class ChatViewModel: ViewModel {
    enum Input {
        case send(message: String)
        case loadChat
    }
    struct Output {
        let myProfile: Profile
        let chatMessageListPublisher: AnyPublisher<[ChatMessageCellModel], Never>
    }

    let output: Output
    private var chatMessages: [ChatMessage]
    private var chatMessageCellModelListSubject: PassthroughSubject<[ChatMessageCellModel], Never>
    private let chatUseCase: ChatUseCaseInterface
    private var cancellables: Set<AnyCancellable>

    public init(
        chatUseCase: ChatUseCaseInterface,
        profileRepository: ProfileRepositoryInterface,
        chatMessages: [ChatMessage]
    ) {
        self.chatUseCase = chatUseCase
        self.chatMessages = chatMessages
        self.chatMessageCellModelListSubject = PassthroughSubject<[ChatMessageCellModel], Never>()
        self.cancellables = []
        output = Output(
            myProfile: profileRepository.loadProfile(),
            chatMessageListPublisher: chatMessageCellModelListSubject.eraseToAnyPublisher()
        )

        receviedMessage()
    }

    func action(input: Input) {
        switch input {
        case .send(let message):
            send(message: message)
        case .loadChat:
            loadChat()
        }
    }

    private func send(message: String) {
        Task {
            await chatUseCase.send(message: message, profile: output.myProfile)
        }
    }

    private func receviedMessage() {
        chatUseCase.chatMessagePublisher
            .sink { [weak self] chatMessage in
                self?.chatMessages.append(chatMessage)
//                guard let convertedMessages = self?.convertToCellModel() else { return }
                self?.loadChat()
            }
            .store(in: &cancellables)
    }
    private func loadChat() {
        chatMessageCellModelListSubject.send(convertToCellModel())
    }

    private func convertToCellModel() -> [ChatMessageCellModel] {
        let sortedMessages = chatMessages
            .sorted { $0.sentAt < $1.sentAt }
        var convertedMessages: [ChatMessageCellModel] = []
        var messageType: ChatMessageType = .last
        for index in 0..<chatMessages.count {
            if index == chatMessages.count-1 {
                switch messageType {
                case .single, .last:
                    messageType = .single
                case .first, .between:
                    messageType = .last
                }
                convertedMessages.append(
                    ChatMessageCellModel(
                        chatMessage: sortedMessages[index],
                        chatMessageType: messageType))
                continue
            }
            if sortedMessages[index].sender == sortedMessages[index+1].sender {
                switch messageType {
                case .single, .last:
                    messageType = .first
                case .first, .between:
                    messageType = .between
                }
            } else {
                switch messageType {
                case .single, .last:
                    messageType = .single
                case .first, .between:
                    messageType = .last
                }
            }
            convertedMessages.append(
                ChatMessageCellModel(
                    chatMessage: sortedMessages[index],
                    chatMessageType: messageType))
        }
        return convertedMessages
    }
}
