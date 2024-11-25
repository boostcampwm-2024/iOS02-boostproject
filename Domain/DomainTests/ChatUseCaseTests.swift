//
//  ChatUseCaseTests.swift
//  DomainTests
//
//  Created by 박승찬 on 11/25/24.
//

import Combine
import Domain
import XCTest

private final class SuccessSendMockChatRepository: ChatRepositoryInterface {
    weak var delegate: ChatRepositoryDelegate?

    func send(message: String, profile: Profile) async -> ChatMessage? {
        let chatMessage = ChatMessage(message: message, sender: profile)
        return chatMessage
    }
}

private final class FailureSendMockChatRepository: ChatRepositoryInterface {
    weak var delegate: ChatRepositoryDelegate?

    func send(message: String, profile: Profile) async -> ChatMessage? {
        return nil
    }
}

final class ChatUseCaseTests: XCTestCase {
    private var useCase: ChatUseCaseInterface!
    private var mockRepository: ChatRepositoryInterface!
    private var cancellables: Set<AnyCancellable>!
    private var myProfile: Profile!

    override func setUpWithError() throws {
        myProfile = Profile(nickname: "승찬", profileIcon: .angel)
        cancellables = []
    }

    override func tearDownWithError() throws {
        useCase = nil
        mockRepository = nil
    }

    // 채팅보내기 성공했을 경우를 테스트
    func testSendChatMessageSuccess() async {
        // 준비
        mockRepository = SuccessSendMockChatRepository()
        useCase = ChatUseCase(chatRepository: mockRepository)
        let message = "안녕하세요?"
        var receivedChatMessage: ChatMessage? = nil
        useCase.chatMessagePublisher
            .sink { receivedChatMessage = $0 }
            .store(in: &cancellables)

        // 실행
        let isSuccess = await useCase.send(message: message, profile: myProfile)

        // 검증
        guard let receivedChatMessage else {
            XCTAssert(false)
            return
        }
        XCTAssertTrue(isSuccess)
        XCTAssertEqual(message, receivedChatMessage.message)
        XCTAssertEqual(myProfile, receivedChatMessage.sender)
    }

    // 채팅보내기 실패했을 경우를 테스트
    func testSendChatMessageFailure() async {
        // 준비
        mockRepository = FailureSendMockChatRepository()
        useCase = ChatUseCase(chatRepository: mockRepository)
        let message = "안녕못해요."
        var receivedChatMessage: ChatMessage? = nil
        useCase.chatMessagePublisher
            .sink { receivedChatMessage = $0 }
            .store(in: &cancellables)

        // 실행
        let isFailure = await useCase.send(message: message, profile: myProfile)

        // 검증
        XCTAssertFalse(isFailure)
        XCTAssertNil(receivedChatMessage)
    }
}
