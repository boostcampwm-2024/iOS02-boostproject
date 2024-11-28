//
//  DefaultWhiteboardRepository.swift
//  DataSource
//
//  Created by 최다경 on 11/12/24.
//

import Combine
import Domain
import Foundation

public final class WhiteboardRepository: WhiteboardRepositoryInterface {
    private var nearbyNetwork: NearbyNetworkInterface
    public weak var delegate: WhiteboardRepositoryDelegate?
    public var recentPeerPublisher: AnyPublisher<Profile, Never>
    private var recentPeerSubject = PassthroughSubject<Profile, Never>()
    private var connections: [UUID: NetworkConnection]
    private var participantsInfo: [String: String]
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var myProfile: Profile
    private var isHost: Bool = false
    private var publishingCandidate: NetworkConnection?
    private var isPublishingCandidate: Bool = false
    private var cancellables: Set<AnyCancellable>

    public init(nearbyNetworkInterface: NearbyNetworkInterface, myProfile: Profile) {
        self.nearbyNetwork = nearbyNetworkInterface
        self.participantsInfo = [:]
        self.connections = [:]
        self.myProfile = myProfile
        cancellables = []
        self.recentPeerPublisher = recentPeerSubject.eraseToAnyPublisher()
        bindNearbyNetwork()
        self.nearbyNetwork.connectionDelegate = self
    }

    public func updateProfile(myProfile: Profile) {
        self.myProfile = myProfile
    }

    public func startPublishing(myProfile: Profile) {
        isHost = true
        self.myProfile = myProfile
        updatePublishingInfo(myProfile: myProfile)
        nearbyNetwork.startPublishing(with: participantsInfo)
    }

    public func startSearching() {
        nearbyNetwork.startSearching()
    }

    public func disconnectWhiteboard() {
        nearbyNetwork.disconnectAll()
        nearbyNetwork.stopPublishing()
        clearConnectionInfo()
    }

    public func joinWhiteboard(whiteboard: Whiteboard, myProfile: Profile) throws {
        isHost = false

        let profileIcons = whiteboard.participantIcons
            .map { $0.emoji }
            .joined(separator: ",")

        let participantsInfo = ["participants": profileIcons]

        let connection = NetworkConnection(
            id: whiteboard.ID,
            name: myProfile.nickname,
            info: participantsInfo)

        let context = RequestedContext(participant: myProfile.profileIcon.emoji, name: myProfile.nickname)

        try nearbyNetwork.joinConnection(connection: connection, context: context)
    }

    public func stopSearching() {
        nearbyNetwork.stopSearching()
    }

    public func restartSearching() {
        nearbyNetwork.restartSearching()
    }

    private func updatePublishingInfo(myProfile: Profile) {
        var newIconList: [String] = []
        newIconList.append(myProfile.profileIcon.emoji)

        for connection in connections.values {
            guard
                let info = connection.info,
                let participant = info["participants"],
                !participant.isEmpty
            else { continue }
            newIconList.append(participant)
        }

        let newInfo = newIconList.joined(separator: ",")
        self.participantsInfo["participants"] = newInfo
        self.participantsInfo["host"] = myProfile.nickname
    }

    private func clearConnectionInfo() {
        self.connections.removeAll()
        self.participantsInfo.removeAll()
        isHost = false
        isPublishingCandidate = false
        publishingCandidate = nil
    }

    private func assignPublishingCandidate() {
        let candidate = connections.values.first
        publishingCandidate = candidate
        sendConnectionInfo()
    }

    private func sendConnectionInfo() {
        guard
            let candidate = publishingCandidate,
            let emojiString = participantsInfo["participants"]
        else { return }
        let emojiToRemove = myProfile.profileIcon.emoji
        let emojiList = emojiString
            .split(separator: ",")
            .map { String($0) }
            .filter { $0 != emojiToRemove }

        let newEmojiString = emojiList.joined(separator: ",")
        var newParticipantsInfo = participantsInfo
        newParticipantsInfo["participants"] = newEmojiString
        let connectionList = connections.map { ($0.key, $0.value) }
        let orderedKeys = connectionList.map { $0.0 }
        let orderedValues = connectionList.map { $0.1 }

        let assinInfo = PublisherInfo(publishingCandidate: candidate,
                                      IDs: orderedKeys,
                                      connections: orderedValues,
                                      participantsInfo: newParticipantsInfo)

        guard let encodedInfo = try? encoder.encode(assinInfo) else { return }
        nearbyNetwork.send(data: encodedInfo)
    }
}

extension WhiteboardRepository: NearbyNetworkConnectionDelegate {
    public func nearbyNetwork(
        _ sender: any NearbyNetworkInterface,
        didReceive data: Data,
        from connection: NetworkConnection) {
        // TODO: -
    }

    public func nearbyNetwork(
        _ sender: any NearbyNetworkInterface,
        didReceive connectionHandler: @escaping (Bool) -> Void) {
            connectionHandler(true)
    }

    public func nearbyNetwork(_ sender: any NearbyNetworkInterface, didFind connections: [NetworkConnection]) {
        let foundWhiteboards = connections.map {
            Whiteboard(
                id: $0.id,
                name: $0.info?["host"] ?? "Unknown",
                participantIcons: toProfileIcon(info: $0.info?["participants"]))
        }

        func toProfileIcon(info: String?) -> [ProfileIcon] {
            guard let info else { return [] }
            let emojis = info
                .split(separator: ",")
                .map { String($0) }
                .compactMap { ProfileIcon(rawValue: $0) }
            return emojis
        }

        delegate?.whiteboardRepository(self, didFind: foundWhiteboards)
    }

    public func nearbyNetwork(_ sender: any NearbyNetworkInterface, didLost connection: NetworkConnection) {
        delegate?.whiteboardRepository(self, didLost: connection.id)
    }

    public func nearbyNetworkCannotConnect(_ sender: any NearbyNetworkInterface) {
        // TODO: -
    }

    public func nearbyNetwork(
        _ sender: any NearbyNetworkInterface,
        didConnect connection: NetworkConnection,
        with info: [String: String]
    ) {
        // TODO: -
    }

    public func nearbyNetwork(
        _ sender: any NearbyNetworkInterface,
        didConnect connection: NetworkConnection,
        with context: Data?
    ) {
        if !isHost { return }

        do {
            guard
                let context = context,
                let prevInfo = self.participantsInfo["participants"]
            else { return }

            let decodedContext = try decoder.decode(RequestedContext.self, from: context)
            let invitationInfo = decodedContext.participant
            let currentInfo = prevInfo + "," + invitationInfo
            let requestedInfo = ["participants": invitationInfo]

            guard let profileIcon = ProfileIcon(rawValue: invitationInfo) else { return }

            let profile = Profile(nickname: decodedContext.name, profileIcon: profileIcon)

            recentPeerSubject.send(profile)

            connections[connection.id] = NetworkConnection(id: connection.id, name: decodedContext.name, info: requestedInfo)
            updatePublishingInfo(myProfile: myProfile)
            nearbyNetwork.startPublishing(with: self.participantsInfo)
            assignPublishingCandidate()
        } catch {
            // TODO: - 에러 처리
        }
    }

    public func nearbyNetwork(
        _ sender: any NearbyNetworkInterface,
        didDisconnect connection: NetworkConnection
    ) {
        if isHost {
            connections[connection.id] = nil
            assignPublishingCandidate()
            updatePublishingInfo(myProfile: myProfile)
            nearbyNetwork.startPublishing(with: self.participantsInfo)
        }

        let lostConnectionName = connection.name
            .map { String($0) }
            .suffix(from: 36)
            .joined()

        let isHostLosted = lostConnectionName == participantsInfo["host"]

        if isHostLosted && isPublishingCandidate {
            guard let hostName = participantsInfo["host"] else { return }
            isHost = true
            participantsInfo["host"] = myProfile.nickname
            connections = connections.filter { $0.value.name != myProfile.nickname }
            assignPublishingCandidate()
            startPublishing(myProfile: myProfile)
        }
    }

    private func bindNearbyNetwork() {
        nearbyNetwork.reciptDataPublisher
            .sink { [weak self] data in
                guard let decodedData = try? JSONDecoder().decode(PublisherInfo.self, from: data) else { return }
                if decodedData.publishingCandidate.name == self?.myProfile.nickname {
                    self?.isPublishingCandidate = true
                } else {
                    self?.isPublishingCandidate = false
                }

                let newConnections = Dictionary(uniqueKeysWithValues: zip(decodedData.IDs, decodedData.connections))
                self?.connections = newConnections
                self?.participantsInfo = decodedData.participantsInfo
            }
            .store(in: &cancellables)
    }
}
