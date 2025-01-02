//
//  NearbyNetworkListener.swift
//  NearbyNetwork
//
//  Created by 최정인 on 12/31/24.
//

import Foundation
import Network
import OSLog

final class NearbyNetworkListener {
    private var nwListener: NWListener?
    private let listenerQueue: DispatchQueue
    private let serviceName: String
    private let serviceType: String
    private let logger: Logger

    init(serviceName: String, serviceType: String) {
        nwListener = try? NWListener(using: .tcp)
        listenerQueue = DispatchQueue.global()
        self.serviceName = serviceName
        self.serviceType = serviceType
        self.logger = Logger()
        configure()
    }

    private func configure() {
        nwListener?.newConnectionHandler = { connection in
            connection.start(queue: self.listenerQueue)
        }
    }

    func startPublishing(hostName: String, connectedPeerInfo: [String]) {
        let connectionData = [
            NearbyNetworkKey.host.rawValue: hostName,
            NearbyNetworkKey.connectedPeerInfo.rawValue: connectedPeerInfo.joined(separator: ",")]
        let txtRecord = NWTXTRecord(connectionData)

        nwListener?.service = NWListener.Service(
            name: serviceName,
            type: serviceType,
            txtRecord: txtRecord)

        nwListener?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                self.logger.log(level: .debug, "NWListener READY")
            case .failed(let error):
                self.logger.log(level: .error, "NWListener Failed \(error.localizedDescription)")
            default:
                break
            }
        }

        nwListener?.start(queue: listenerQueue)
    }

    func stopPublishing() {
        nwListener?.cancel()
    }
}
