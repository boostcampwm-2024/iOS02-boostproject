//
//  ChatRepository.swift
//  DataSource
//
//  Created by 박승찬 on 11/24/24.
//

import Domain
import OSLog

public final class ChatRepository: ChatRepositoryInterface {
    public weak var delegate: ChatRepositoryDelegate?
    private var nearbyNetwork: NearbyNetworkInterface
    private let filePersistence: FilePersistenceInterface
    private let profileKey = "AirplainProfile"
    private let logger = Logger()

    init(
        delegate: ChatRepositoryDelegate?,
        nearbyNetwork: NearbyNetworkInterface,
        filePersistence: FilePersistenceInterface
    ) {
        self.delegate = delegate
        self.nearbyNetwork = nearbyNetwork
        self.filePersistence = filePersistence
        self.nearbyNetwork.receiptDelegate = self
    }

    public func send(message: String, profile: Profile) async -> ChatMessage? {
        let chatMessage = ChatMessage(message: message, sender: profile)
        let chatMessageData = try? JSONEncoder().encode(chatMessage)
        let chatMessageInformation = DataInformationDTO(
            id: profile.id,
            type: .chat,
            isDeleted: false)
        guard let url = filePersistence
            .save(dataInfo: chatMessageInformation, data: chatMessageData)
        else {
            logger.log(level: .error, "url저장 실패: 데이터를 보내지 못했습니다.")
            return nil
        }
        await nearbyNetwork.send(fileURL: url, info: chatMessageInformation)

        return chatMessage
    }
}

extension ChatRepository: NearbyNetworkReceiptDelegate {
    // TODO: 사용안할 메소드
    public func nearbyNetwork(_ sender: any NearbyNetworkInterface, didReceive data: Data) { }

    public func nearbyNetwork(
        _ sender: any NearbyNetworkInterface,
        didReceiveURL URL: URL,
        info: DataInformationDTO
    ) {
        guard let receiveData = filePersistence.load(path: URL) else { return }
        filePersistence.save(dataInfo: info, data: receiveData)
        guard let chatMessage = try? JSONDecoder().decode(ChatMessage.self,
            from: receiveData)
        else {
            logger.log(level: .error, "WhiteboardObjectRepository: 전달받은 데이터 디코딩 실패")
            return
        }

        delegate?.chatRepository(self, didReceive: chatMessage)
    }
}
