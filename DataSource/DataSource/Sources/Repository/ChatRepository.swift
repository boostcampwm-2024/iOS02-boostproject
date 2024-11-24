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
    private let profilePersistence: PersistenceInterface
    private let filePersistence: FilePersistenceInterface
    private let profileKey = "AirplainProfile"
    private let logger = Logger()

    init(
        delegate: ChatRepositoryDelegate?,
        nearbyNetwork: NearbyNetworkInterface,
        profilePersistence: PersistenceInterface,
        filePersistence: FilePersistenceInterface
    ) {
        self.delegate = delegate
        self.nearbyNetwork = nearbyNetwork
        self.profilePersistence = profilePersistence
        self.filePersistence = filePersistence
    }

    public func send(message: String) async {
        let profile = loadProfile()
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
            return
        }
        await nearbyNetwork.send(fileURL: url, info: chatMessageInformation)
    }

    private func loadProfile() -> Profile {
        if let profile: Profile = profilePersistence.load(forKey: profileKey) {
            return profile
        } else {
            let randomProfile = Profile(
                nickname: Profile.randomNickname(),
                profileIcon: ProfileIcon.allCases.randomElement() ?? ProfileIcon.angel)
            profilePersistence.save(data: randomProfile, forKey: profileKey)
            return randomProfile
        }
    }
}

extension ChatRepository: NearbyNetworkReceiptDelegate {
    // TODO: 사용안할 메소드
    public func nearbyNetwork(_ sender: any NearbyNetworkInterface, didReceive data: Data) { }

    public func nearbyNetwork(
        _ sender: any NearbyNetworkInterface,
        didReceiveURL URL: URL,
        info: DataInformationDTO
    ) { }
}
