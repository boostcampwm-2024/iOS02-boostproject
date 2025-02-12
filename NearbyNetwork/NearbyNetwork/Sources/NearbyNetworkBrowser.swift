//
//  NearbyNetworkBrowser.swift
//  NearbyNetwork
//
//  Created by 최정인 on 12/31/24.
//

import DataSource
import Foundation
import Network
import OSLog

public protocol NearbyNetworkBrowserDelegate: AnyObject {
    func nearbyNetworkBrowserDidFindPeer(
        _ sender: NearbyNetworkBrowser,
        foundPeers: [NetworkConnection])
}

public final class NearbyNetworkBrowser {
    private let nwBrowser: NWBrowser
    private let browserQueue: DispatchQueue
    private let serviceType: String
    private let logger: Logger
    private var foundPeers: [NetworkConnection: NWEndpoint] {
        didSet {
            let foundPeers = foundPeers
                .keys
                .sorted(by: { $0.name < $1.name })
            delegate?.nearbyNetworkBrowserDidFindPeer(self, foundPeers: Array(foundPeers))
        }
    }
    weak var delegate: NearbyNetworkBrowserDelegate?

    init(serviceType: String, networkParameter: NWParameters) {
        nwBrowser = NWBrowser(
            for: .bonjourWithTXTRecord(type: serviceType, domain: nil),
            using: networkParameter)
        self.browserQueue = DispatchQueue.global()
        self.serviceType = serviceType
        self.logger = Logger()
        self.foundPeers = [:]
        configure()
    }

    private func configure() {
        nwBrowser.browseResultsChangedHandler = browserHandler
    }

    private func browserHandler(results: Set<NWBrowser.Result>, changes: Set<NWBrowser.Result.Change>) {
        for change in changes {
            switch change {
            case .added(let result):
                guard let foundPeer = convertMetadata(metadata: result.metadata) else { return }
                foundPeers[foundPeer] = result.endpoint
            case .removed(let result):
                guard let foundPeer = convertMetadata(metadata: result.metadata) else { return }
                foundPeers[foundPeer] = nil
            default:
                break
            }
        }
    }

    private func convertMetadata(metadata: NWBrowser.Result.Metadata) -> NetworkConnection? {
        switch metadata {
        case .bonjour(let foundedPeerData):
            let dictionary = foundedPeerData.dictionary
            guard
                let peerIDString = dictionary[NearbyNetworkKey.peerID.rawValue],
                let peerID = UUID(uuidString: peerIDString),
                let hostName = dictionary[NearbyNetworkKey.host.rawValue],
                let connectedPeerInfo = dictionary[NearbyNetworkKey.connectedPeerInfo.rawValue]
            else {
                logger.log(level: .error, "connection의 데이터 값이 유효하지 않습니다.")
                return nil
            }

            let foundPeer = NetworkConnection(
                id: peerID,
                name: hostName,
                connectedPeerInfo: connectedPeerInfo
                    .split(separator: ",")
                    .map { String($0) })
            return foundPeer
        default:
            logger.log(level: .error, "알 수 없는 피어가 발견되었습니다.")
            return nil
        }
    }

    func fetchFoundConnection(networkConnection: NetworkConnection) -> NWEndpoint? {
        return foundPeers[networkConnection]
    }

    func startSearching() {
        nwBrowser.start(queue: browserQueue)
    }

    func stopSearching() {
        nwBrowser.cancel()
    }
}
