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
    }
    struct Output {
        let myProfile: Profile
        let chatMessageListPublisher: AnyPublisher<[ChatMessage], Never>
    }

    let output: Output
    private var chatMessageList: CurrentValueSubject<[ChatMessage], Never>
    private let chatUseCase: ChatUseCaseInterface
    private var cancellables: Set<AnyCancellable>

    public init(myProfile: Profile, chatUseCase: ChatUseCaseInterface) {
        self.chatUseCase = chatUseCase
        self.chatMessageList = CurrentValueSubject<[ChatMessage], Never>([])
        self.cancellables = []
        output = Output(
            myProfile: myProfile,
            chatMessageListPublisher: chatMessageList.eraseToAnyPublisher()
        )

        receviedMessage()
    }

    func action(input: Input) {
        switch input {
        case .send(let message):
            send(message: message)
        }
    }

    private func send(message: String) {
        Task {
            await chatUseCase.send(message: message, profile: output.myProfile)
        }
    }

    private func receviedMessage() {
        chatUseCase.chatMessagePublisher
            .sink { [weak self] in
                self?.chatMessageList.value.append($0)
            }
            .store(in: &cancellables)
    }
}
