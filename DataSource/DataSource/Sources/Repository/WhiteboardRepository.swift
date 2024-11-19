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

    public init(nearbyNetworkInterface: NearbyNetworkInterface) {
        self.nearbyNetwork = nearbyNetworkInterface
        self.nearbyNetwork.delegate = self
    }

    public func startPublishing(with info: [Profile]) {
        let participantsInfo: [String: String] = ["participants": info
            .compactMap { $0.profileIcon.emoji }
            .joined(separator: ",")]
        nearbyNetwork.startPublishing(with: participantsInfo)
    }

    public func startSearching() {
        nearbyNetwork.startSearching()
    }

    public func joinWhiteboard(whiteboard: WhiteboardListEntity) throws {
        let participantsInfo = ["participants": whiteboard.info.joined(separator: ",")]
        let connection = NetworkConnection(
            id: whiteboard.id,
            name: whiteboard.name,
            info: participantsInfo)
        try nearbyNetwork.joinConnection(connection: connection)
    }
}

extension WhiteboardRepository: NearbyNetworkDelegate {
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
        let foundWhiteboards = connections.compactMap {
            WhiteboardListEntity(
                id: $0.id,
                name: $0.name,
                info: toProfileEmoji(information: $0.info?["participants"] ?? ""))
        }

        func toProfileEmoji(information: String) -> [String] {
            return information.split(separator: ",").map { String($0) }
        }

        delegate?.whiteboardRepository(self, didFind: foundWhiteboards)
    }

    public func nearbyNetworkCannotConnect(_ sender: any NearbyNetworkInterface) {
        // TODO: -
    }
}
