//
//  ChatRepository.swift
//  DataSource
//
//  Created by 박승찬 on 11/24/24.
//

import Combine
import Domain
import OSLog

public final class ChatRepository: ChatRepositoryInterface {
    public weak var delegate: ChatRepositoryDelegate?
    private var nearbyNetwork: NearbyNetworkInterface
    private let filePersistence: FilePersistenceInterface
    private var cancellables: Set<AnyCancellable>
    private let logger = Logger()

    public init(
        nearbyNetwork: NearbyNetworkInterface,
        filePersistence: FilePersistenceInterface
    ) {
        self.nearbyNetwork = nearbyNetwork
        self.filePersistence = filePersistence
        cancellables = []
        bindNearbyNetwork()
    }

    public func send(message: String, profile: Profile) async -> ChatMessage? {
        let chatMessage = ChatMessage(message: message, sender: profile)
        guard let chatMessageData = try? JSONEncoder().encode(chatMessage) else { return nil }

        let chatMessageDTO = AirplaINDataDTO(
            id: profile.id,
            data: chatMessageData,
            type: .chat,
            isDeleted: false)

        guard
            let url = filePersistence.save(dto: chatMessageDTO)
        else {
            logger.log(level: .error, "url저장 실패: 데이터를 보내지 못했습니다.")
            return nil
        }

        _ = await nearbyNetwork.send(data: chatMessageDTO)
        return chatMessage
    }

    private func bindNearbyNetwork() {
        nearbyNetwork.reciptDataPublisher
            .sink { [weak self] dto in
                guard dto.type == .chat else { return }
                self?.handleChatData(dto: dto)
            }
            .store(in: &cancellables)
    }

    private func handleChatData(dto: AirplaINDataDTO) {
        let receivedData = dto.data

        guard
            let chatMessage = try? JSONDecoder().decode(
                ChatMessage.self,
                from: receivedData)
        else {
            logger.log(level: .error, "WhiteboardObjectRepository: 전달받은 데이터 디코딩 실패")
            return
        }

        delegate?.chatRepository(self, didReceive: chatMessage)
    }
}
