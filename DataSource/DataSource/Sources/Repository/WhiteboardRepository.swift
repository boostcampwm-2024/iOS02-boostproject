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
        didReceive connectionHandler: @escaping (
            Bool
        ) -> Void) {
        // TODO: -
    }

    public func nearbyNetwork(_ sender: any NearbyNetworkInterface, didFind connections: [NetworkConnection]) {
        let foundWhiteboards = connections.map {
            WhiteboardCellModel(
                id: $0.id,
                title: $0.name,
                icons: toProfileIcon(info: $0.info?["participants"]))
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

    public func nearbyNetworkCannotConnect(_ sender: any NearbyNetworkInterface) {
        // TODO: -
    }
}
