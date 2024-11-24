//
//  DefaultWhiteboardRepository.swift
//  DataSource
//
//  Created by 최다경 on 11/12/24.
//

import Domain
import Foundation

public final class WhiteboardRepository: WhiteboardRepositoryInterface {
    private var nearbyNetwork: NearbyNetworkInterface
    public weak var delegate: WhiteboardRepositoryDelegate?
    private var connections: [UUID: NetworkConnection]
    private var participantsInfo: [String: String]
    private let decoder = JSONDecoder()
    private let myProfile: Profile

    public init(nearbyNetworkInterface: NearbyNetworkInterface, myProfile: Profile) {
        self.nearbyNetwork = nearbyNetworkInterface
        self.participantsInfo = [:]
        self.connections = [:]
        self.myProfile = myProfile
        self.nearbyNetwork.connectionDelegate = self
    }

    public func startPublishing() {
        updatePublishingInfo()
        nearbyNetwork.startPublishing(with: participantsInfo)
    }

    public func startSearching() {
        nearbyNetwork.startSearching()
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

        let context = RequestedContext(participant: myProfile.profileIcon.emoji)

        try nearbyNetwork.joinConnection(connection: connection, context: context)
    }

    public func stopSearching() {
        nearbyNetwork.stopSearching()
    }

    private func updatePublishingInfo() {
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
        let lostedWhiteboard = Whiteboard(
            id: connection.id,
            name: "",
            participantIcons: []
        )
        delegate?.whiteboardRepository(self, didLost: lostedWhiteboard.id)
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
        if !isHost { return }

        do {
            guard
                let context = context,
                let prevInfo = self.participantsInfo["participants"]
            else { return }

            let decodedContext = try JSONDecoder().decode(RequestedContext.self, from: context)
            let invitationInfo = decodedContext.participant
            let currentInfo = prevInfo + "," + invitationInfo
            let requestedInfo = ["participants": invitationInfo]

            connections[connection.id] = NetworkConnection(id: connection.id, name: "", info: requestedInfo)
            updatePublishingInfo()
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
        guard
            let prevInfo = self.participantsInfo["participants"],
            let lostConnection = connections[connection.id],
            let lostInfo = lostConnection.info,
            let lostIcon = lostInfo["participants"]
        else { return }


        connections[connection.id] = nil
        updatePublishingInfo()
        nearbyNetwork.startPublishing(with: self.participantsInfo)
    }
}
