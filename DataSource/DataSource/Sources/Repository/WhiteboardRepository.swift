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
    public weak var delegate: WhiteboardRepositoryDelegate?
    public let recentPeerPublisher: AnyPublisher<Profile, Never>
    private var nearbyNetwork: NearbyNetworkInterface
    private var connections: [UUID: NetworkConnection]
    private var participantsInfo: [String: String]
    private let decoder = JSONDecoder()
    private var myProfile: Profile
    private var recentPeerSubject = PassthroughSubject<Profile, Never>()

    public init(nearbyNetworkInterface: NearbyNetworkInterface, myProfile: Profile) {
        self.nearbyNetwork = nearbyNetworkInterface
        self.participantsInfo = [:]
        self.connections = [:]
        self.myProfile = myProfile
        self.recentPeerPublisher = recentPeerSubject.eraseToAnyPublisher()
        self.nearbyNetwork.connectionDelegate = self
    }

    public func startPublishing(myProfile: Profile) {
        self.myProfile = myProfile
        updatePublishingInfo(myProfile: myProfile)
        nearbyNetwork.startPublishing(with: participantsInfo)
    }

    public func disconnectWhiteboard() {
        nearbyNetwork.disconnectAll()
        nearbyNetwork.stopPublishing()
    }

    public func joinWhiteboard(whiteboard: Whiteboard, myProfile: Profile) throws {
        let profileIcons = whiteboard.participantIcons
            .map { $0.emoji }
            .joined(separator: ",")

        let participantsInfo = ["participants": profileIcons]

        let connection = NetworkConnection(
            id: whiteboard.id,
            name: whiteboard.name,
            info: participantsInfo)

        let context = RequestedContext(nickname: myProfile.nickname, participant: myProfile.profileIcon.emoji)

        try nearbyNetwork.joinConnection(connection: connection, context: context)
    }

    public func stopSearching() {
        nearbyNetwork.stopSearching()
    }

    public func startSearching() {
        nearbyNetwork.startSearching()
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
        with context: Data?,
        isHost: Bool
    ) {
        do {
            guard
                isHost,
                let context = context,
                let prevInfo = self.participantsInfo["participants"]
            else { return }

            let decodedContext = try JSONDecoder().decode(RequestedContext.self, from: context)
            let invitationInfo = decodedContext.participant
            let requestedInfo = ["participants": invitationInfo]

            guard let connectedProfileIcon = ProfileIcon(rawValue: invitationInfo) else { return }

            let connectedProfile = Profile(
                id: connection.id,
                nickname: decodedContext.nickname,
                profileIcon: connectedProfileIcon)

            recentPeerSubject.send(connectedProfile)

            connections[connection.id] = NetworkConnection(id: connection.id, name: "", info: requestedInfo)
            updatePublishingInfo(myProfile: myProfile)
            nearbyNetwork.startPublishing(with: self.participantsInfo)
        } catch {
            // TODO: - 에러 처리
        }
    }

    public func nearbyNetwork(
        _ sender: any NearbyNetworkInterface,
        didDisconnect connection: NetworkConnection,
        isHost: Bool
    ) {
        if !isHost { return }

        connections[connection.id] = nil
        updatePublishingInfo(myProfile: myProfile)
        nearbyNetwork.startPublishing(with: self.participantsInfo)
    }
}
