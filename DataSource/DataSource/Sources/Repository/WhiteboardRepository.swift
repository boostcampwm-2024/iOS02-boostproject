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

    public func startPublishing() {
        nearbyNetwork.startPublishing()
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
        let foundWhiteboards = connections.map { Whiteboard(name: $0.name) }
        delegate?.whiteboardRepository(self, didFind: foundWhiteboards)
    }

    public func nearbyNetworkCannotConnect(_ sender: any NearbyNetworkInterface) {
        // TODO: -
    }
}
