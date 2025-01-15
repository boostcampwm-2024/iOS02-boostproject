//
//  WhiteboardListRepository.swift
//  DataSource
//
//  Created by 최정인 on 1/10/25.
//

import Combine
import Domain
import Foundation

public final class WhiteboardListRepository: WhiteboardListRepositoryInterface {
    public weak var delegate: WhiteboardListRepositoryDelegate?
    private var nearbyNetworkService: NearbyNetworkInterface

    init(nearbyNetworkService: NearbyNetworkInterface) {
        self.nearbyNetworkService = nearbyNetworkService
        self.nearbyNetworkService.searchingDelegate = self
    }

    public func startPublishing(myProfile: Profile, paritipantIcons: [ProfileIcon]) {
        nearbyNetworkService.startPublishing(
            with: myProfile.nickname,
            connectedPeerInfo: paritipantIcons.map { $0.emoji })
    }

    public func stopPublishing() {
        nearbyNetworkService.stopPublishing()
    }

    public func startSearching() {
        nearbyNetworkService.startSearching()
    }

    public func stopSearching() {
        nearbyNetworkService.stopSearching()
    }

    public func joinWhiteboard(whiteboard: Whiteboard, myProfile: Profile) async -> Bool {
        let connection = NetworkConnection(
            id: whiteboard.id,
            name: whiteboard.name,
            connectedPeerInfo: whiteboard.participantIcons.map { $0.emoji })

        let myInfo = RequestedContext(
            peerID: myProfile.id,
            nickname: myProfile.nickname,
            participant: myProfile.profileIcon.emoji)

        let result = await nearbyNetworkService.joinConnection(
            connection: connection,
            myConnectionInfo: myInfo)

        return result
    }

    private func convertToWhiteboard(connection: NetworkConnection) -> Whiteboard {
        let participantIcons = connection
            .connectedPeerInfo
            .compactMap { ProfileIcon(rawValue: $0) }

        let whiteboard = Whiteboard(
            id: connection.id,
            name: connection.name,
            participantIcons: participantIcons)

        return whiteboard
    }
}

extension WhiteboardListRepository: NearbyNetworkSearchingDelegate {
    public func nearbyNetwork(_ sender: NearbyNetworkInterface, didFind connection: NetworkConnection) {
        let whiteboard = convertToWhiteboard(connection: connection)
        delegate?.whiteboardListRepository(self, didFind: whiteboard)
    }

    public func nearbyNetwork(_ sender: NearbyNetworkInterface, didLost connection: NetworkConnection) {
        let whiteboard = convertToWhiteboard(connection: connection)
        delegate?.whiteboardListRepository(self, didLost: whiteboard)
    }
}
