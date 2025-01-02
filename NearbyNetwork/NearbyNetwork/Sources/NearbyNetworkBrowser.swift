//
//  NearbyNetworkBrowser.swift
//  NearbyNetwork
//
//  Created by 최정인 on 12/31/24.
//

import Foundation
import Network
import OSLog

public protocol NearbyNetworkBrowserDelegate: AnyObject {
    func nearbyNetworkBrowserDidFindPeer(
        _ sender: NearbyNetworkBrowser,
        hostName: String,
        connectedPeerInfo: [String])
}

public final class NearbyNetworkBrowser {
    private let nwBrowser: NWBrowser
    private let browserQueue: DispatchQueue
    private let serviceType: String
    private let logger: Logger
    weak var delegate: NearbyNetworkBrowserDelegate?

    init(serviceType: String) {
        nwBrowser = NWBrowser(
            for: .bonjourWithTXTRecord(type: serviceType, domain: nil),
            using: .tcp)
        self.browserQueue = DispatchQueue.global()
        self.serviceType = serviceType
        self.logger = Logger()
        configure()
    }

    private func configure() {
        nwBrowser.browseResultsChangedHandler = browserHandler
    }

    private func browserHandler(results: Set<NWBrowser.Result>, changes: Set<NWBrowser.Result.Change>) {
        for result in results {
            switch result.metadata {
            case .bonjour(let foundedPeerData):
                let dictionary = foundedPeerData.dictionary
                guard
                    let hostName = dictionary[NearbyNetworkKey.host.rawValue],
                    let connectedPeerInfo = dictionary[NearbyNetworkKey.connectedPeerInfo.rawValue]
                else {
                    logger.log(level: .error, "connection의 데이터 값이 유효하지 않습니다.")
                    return
                }

                delegate?.nearbyNetworkBrowserDidFindPeer(
                        self,
                        hostName: hostName,
                        connectedPeerInfo: connectedPeerInfo
                            .split(separator: ",")
                            .map { String($0) })
            default:
                logger.log(level: .error, "알 수 없는 피어가 발견되었습니다.")
            }
        }
    }

    func startSearching() {
        nwBrowser.start(queue: browserQueue)
    }

    func stopSearching() {
        nwBrowser.cancel()
    }
}
