//
//  NearbyNetworkListener.swift
//  NearbyNetwork
//
//  Created by 최정인 on 12/31/24.
//

import Foundation
import Network
import OSLog

public protocol NearbyNetworkListenerDelegate: AnyObject {
    /// 주변 기기와 연결에 성공하였을 때 실행됩니다.
    /// - Parameters:
    ///   - didConnect: 연결된 기기
    func nearbyNetworkListener(_ sender: NearbyNetworkListener, didConnect connection: NWConnection)

    /// 주변 기기와 연결이 끊겼을 때 실행됩니다.
    /// - Parameters:
    ///   - didDisconnect: 연결이 끊긴 기기
    func nearbyNetworkListener(_ sender: NearbyNetworkListener, didDisconnect connection: NWConnection)

    /// 주변 기기와 연결에 실패했을 때 실행됩니다.
    /// - Parameters:
    ///   - connection: 연결에 실패한 기기
    func nearbyNetworkListenerCannotConnect(_ sender: NearbyNetworkListener, connection: NWConnection)
}

public final class NearbyNetworkListener {
    weak var delegate: NearbyNetworkListenerDelegate?
    private var nwListener: NWListener?
    private let listenerQueue: DispatchQueue
    private let peerID: UUID
    private let serviceName: String
    private let serviceType: String
    private let logger: Logger

    init(
        peerID: UUID,
        serviceName: String,
        serviceType: String,
        networkParameter: NWParameters
    ) {
        nwListener = try? NWListener(using: networkParameter)
        listenerQueue = DispatchQueue.global()
        self.peerID = peerID
        self.serviceName = serviceName
        self.serviceType = serviceType
        self.logger = Logger()
        configure()
    }

    private func configure() {
        nwListener?.newConnectionHandler = { connection in
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    self.logger.log(level: .debug, "\(connection.debugDescription)와 연결되었습니다.")
                    self.delegate?.nearbyNetworkListener(self, didConnect: connection)
                case .failed:
                    self.logger.log(level: .debug, "\(connection.debugDescription)와 연결에 실패했습니다")
                    self.delegate?.nearbyNetworkListenerCannotConnect(self, connection: connection)
                case .cancelled:
                    self.logger.log(level: .debug, "\(connection.debugDescription)와 연결이 끊어졌습니다.")
                    self.delegate?.nearbyNetworkListener(self, didDisconnect: connection)
                default:
                    self.logger.log(level: .debug, "\(connection.debugDescription)와 연결 설정 중입니다.")
                }
            }
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
