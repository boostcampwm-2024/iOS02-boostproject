//
//  NearbyNetworkBrowser.swift
//  NearbyNetwork
//
//  Created by 최정인 on 12/31/24.
//

import Foundation
import Network
import OSLog

final class NearbyNetworkBrowser {
    let nwBrowser: NWBrowser
    private let browserQueue: DispatchQueue
    private let serviceType: String
    private let logger: Logger

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
                // TODO: - 추후 발견한 데이터 이용
                print("")
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
