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
    private let peerID: UUID
    private let serviceName: String
    private let serviceType: String
    private let logger: Logger

    init(
        peerID: UUID,
        serviceName: String,
        serviceType: String
    ) {
        let option = NWProtocolFramer.Options(definition: NearbyNetworkProtocol.definition)
        let parameter = NWParameters.tcp
        parameter.defaultProtocolStack
            .applicationProtocols
            .insert(option, at: 0)
        nwListener = try? NWListener(using: parameter)
        listenerQueue = DispatchQueue.global()
        self.peerID = peerID
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
            NearbyNetworkKey.peerID.rawValue: peerID.uuidString,
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
