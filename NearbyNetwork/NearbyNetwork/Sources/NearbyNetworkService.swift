//
//  NearbyNetworkService.swift
//  NearbyNetwork
//
//  Created by 이동현 on 12/30/24.
//

import Combine
import DataSource
import Foundation
import Network
import OSLog

// TODO: - 추후 기능 동작 확인 후 NearbyNetworkService 대체
public final class NearbyNetworkService {
    public var connectionDelegate: NearbyNetworkConnectionDelegate?
    public var searchingDelegate: NearbyNetworkSearchingDelegate?
    public var foundPeerHandler: ((_ networkConnections: [NetworkConnection]) -> Void)?
    public let reciptDataPublisher: AnyPublisher<AirplaINDataDTO, Never>
    private let reciptDataSubject: PassthroughSubject<AirplaINDataDTO, Never>
    private let serviceName: String
    private let serviceType: String
    private let peerID: UUID
    private let nearbyNetworkParameter: NWParameters
    private let nearbyNetworkListener: NearbyNetworkListener
    private let nearbyNetworkBrowser: NearbyNetworkBrowser
    private let nearbyNetworkServiceQueue: DispatchQueue
    private let logger: Logger
    private var nearbyNetworkConnections: [NetworkConnection: NWConnection]
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    public init(
        myPeerID: UUID,
        serviceName: String,
        serviceType: String
    ) {
        peerID = myPeerID
        nearbyNetworkServiceQueue = DispatchQueue.global()
        logger = Logger()

        let option = NWProtocolFramer.Options(definition: NearbyNetworkProtocol.definition)
        let tcpOption = NWProtocolTCP.Options()
        tcpOption.enableKeepalive = true
        tcpOption.keepaliveIdle = 5
        tcpOption.keepaliveCount = 2
        tcpOption.keepaliveInterval = 3
        tcpOption.connectionTimeout = 5
        tcpOption.connectionDropTime = 5
        tcpOption.persistTimeout = 5
        nearbyNetworkParameter = NWParameters(tls: nil, tcp: tcpOption)

        nearbyNetworkParameter.defaultProtocolStack
            .applicationProtocols
            .insert(option, at: 0)
        nearbyNetworkParameter.includePeerToPeer = true

        nearbyNetworkListener = NearbyNetworkListener(
            peerID: peerID,
            serviceName: serviceName,
            serviceType: serviceType,
            networkParameter: nearbyNetworkParameter)
        nearbyNetworkBrowser = NearbyNetworkBrowser(
            serviceType: serviceType,
            networkParameter: nearbyNetworkParameter)
        nearbyNetworkConnections = [:]
        jsonEncoder = JSONEncoder()
        jsonDecoder = JSONDecoder()
        reciptDataSubject = PassthroughSubject<AirplaINDataDTO, Never>()
        reciptDataPublisher = reciptDataSubject.eraseToAnyPublisher()
        self.serviceName = serviceName
        self.serviceType = serviceType
        nearbyNetworkBrowser.delegate = self
        nearbyNetworkListener.delegate = self
    }

    private func configureConnection(connection: NWConnection) {
        connection.receiveMessage { [weak self] content, contentContext, _, error in
            guard let self else { return }

            let protocolMetadata = contentContext?.protocolMetadata(definition: NearbyNetworkProtocol.definition)
            guard
                let message = protocolMetadata as? NWProtocolFramer.Message
            else {
                self.logger.log(level: .error, "\(connection.debugDescription): 헤더 정보를 확인할 수 없습니다")
                return
            }

            let messageType = message.nearbyNetworkMessageType
            switch messageType {
            case .invalid:
                self.logger.log(level: .error, "\(connection.debugDescription): 유효하지 않은 헤더입니다.")
            case .peerInfo:
                handleNewPeer(peerData: content, connection: connection)
            case .data:
                // TODO: - 데이터 수신 처리
                handleReceivedData(data: content, connection: connection)
            }

            // error가 아니라면, 계속해서 데이터 수신
            if error == nil {
                configureConnection(connection: connection)
            } else {
                // connection을 다시 establish 해야 함!
            }
        }
    }

    private func handleNewPeer(peerData: Data?, connection: NWConnection) {
        guard
            let peerData,
            let connectionInfo = try? jsonDecoder.decode(RequestedContext.self, from: peerData)
        else {
            self.logger.log(level: .error, "\(connection.debugDescription): RequestedContext로 디코딩에 실패했습니다.")
            return
        }

        let networkConnection = NetworkConnection(
            id: connectionInfo.peerID,
            name: connectionInfo.nickname,
            connectedPeerInfo: [connectionInfo.participant])
        self.nearbyNetworkConnections[networkConnection] = connection
        self.connectionDelegate?.nearbyNetwork(self, didConnect: networkConnection)
        self.logger.log(level: .debug, "\(networkConnection): 데이터 수신")
    }

    private func handleReceivedData(data: Data?, connection: NWConnection) {
        guard
            let data,
            let dataDTO = try? jsonDecoder.decode(AirplaINDataDTO.self, from: data)
        else { return }

        reciptDataSubject.send(dataDTO)
        self.logger.log(level: .debug, "\(connection.debugDescription): 데이터 수신")
    }

    private func send(data: AirplaINDataDTO, connection: NWConnection) async -> Bool {
        typealias Continuation = CheckedContinuation<Bool, Never>
        var tryCount = 0

        let encodedData = try? jsonEncoder.encode(data)
        let message = NWProtocolFramer.Message(nearbyNetworkMessageType: .data)
        let context = NWConnection.ContentContext(identifier: "Data", metadata: [message])

        while tryCount < 3 {
            let result = await withCheckedContinuation { (continuation: Continuation) in
                connection.send(
                    content: encodedData,
                    contentContext: context,
                    completion: .contentProcessed({ error in
                        if let error {
                            continuation.resume(returning: false)
                        } else {
                            continuation.resume(returning: true)
                        }
                    }))
            }

            if result { return true }
            tryCount += 1
        }

        return false
    }
}

// MARK: - NearbyNetworkInterface 메서드 구현
extension NearbyNetworkService: NearbyNetworkInterface {
    public func startSearching() {
        nearbyNetworkBrowser.startSearching()
    }

    public func stopSearching() {
        nearbyNetworkBrowser.stopSearching()
    }

    public func startPublishing(with hostName: String, connectedPeerInfo: [String]) {
        nearbyNetworkListener.startPublishing(
            hostName: hostName,
            connectedPeerInfo: connectedPeerInfo)
    }

    public func stopPublishing() {
        nearbyNetworkListener.stopPublishing()
    }

    public func disconnectAll() {
        for connection in nearbyNetworkConnections.values {
            connection.cancel()
        }
        nearbyNetworkConnections.removeAll()
    }

    public func joinConnection(connection: NetworkConnection, context: RequestedContext) throws {
    }

    public func joinConnection(
        connection: NetworkConnection,
        myConnectionInfo: RequestedContext
    ) async -> Bool {
        guard let endpoint = nearbyNetworkBrowser.fetchFoundConnection(networkConnection: connection)
        else { return false }

        let option = NWProtocolFramer.Options(definition: NearbyNetworkProtocol.definition)
        let parameter = NWParameters.tcp
        parameter.defaultProtocolStack
            .applicationProtocols
            .insert(option, at: 0)

        let nwConnection = NWConnection(to: endpoint, using: parameter)

        typealias Continuation = CheckedContinuation<Bool, Never>
        let stateHandler: (@Sendable (NWConnection.State) -> Void) = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready:
                self.logger.log(level: .debug, "\(connection)와 연결되었습니다.")
                let encodedMyConnectionInfo = try? jsonEncoder.encode(myConnectionInfo)
                let message = NWProtocolFramer.Message(nearbyNetworkMessageType: .peerInfo)
                let context = NWConnection.ContentContext(identifier: "ConnectedPeerInfo", metadata: [message])
                // TODO: - 연결 실패 시 delegate로 실패 했음 알려주기
                nwConnection.send(
                    content: encodedMyConnectionInfo,
                    contentContext: context,
                    completion: .idempotent)
                self.connectionDelegate?.nearbyNetwork(self, didConnect: connection)
                self.nearbyNetworkConnections[connection] = nwConnection
            case .failed, .cancelled:
                self.logger.log(level: .debug, "\(connection)와 연결이 끊어졌습니다.")
                self.connectionDelegate?.nearbyNetwork(self, didDisconnect: connection)
                self.nearbyNetworkConnections[connection] = nil
            default:
                self.logger.log(level: .debug, "\(connection)와 연결 설정 중입니다.")
            }
        }

        let result = await withCheckedContinuation { (continuation: Continuation) in
            nwConnection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    nwConnection.stateUpdateHandler = stateHandler
                    continuation.resume(returning: true)
                case .failed, .cancelled:
                    nwConnection.stateUpdateHandler = stateHandler
                    continuation.resume(returning: false)
                default:
                    break
                }
            }
            nwConnection.start(queue: nearbyNetworkServiceQueue)
        }
        return result
    }

    public func send(data: AirplaINDataDTO) async -> Bool {
        let result: Bool = await withTaskGroup(of: Bool.self, returning: Bool.self) { taskGroup in
            for connection in nearbyNetworkConnections.values {
                taskGroup.addTask {
                    return await self.send(data: data, connection: connection)
                }
            }
            for await childResult in taskGroup {
                if !childResult { return false }
            }
            return true
        }
        return result
    }

    public func send(data: AirplaINDataDTO, to connection: NetworkConnection) async -> Bool {
        guard let connection = nearbyNetworkConnections[connection] else { return false }
        return await send(data: data, connection: connection)
    }
}

// MARK: - NearbyNetworkBrowserDelegate
extension NearbyNetworkService: NearbyNetworkBrowserDelegate {
    public func nearbyNetworkBrowserDidFindPeer(
        _ sender: NearbyNetworkBrowser,
        foundPeers: [NetworkConnection]
    ) {
        guard let foundPeerHandler else { return }
        foundPeerHandler(foundPeers)
    }
}

extension NearbyNetworkService: NearbyNetworkListenerDelegate {
    public func nearbyNetworkListener(_ sender: NearbyNetworkListener, didConnect connection: NWConnection) {
        configureConnection(connection: connection)
    }

    public func nearbyNetworkListener(_ sender: NearbyNetworkListener, didDisconnect connection: NWConnection) {
        guard
            let networkConnection = nearbyNetworkConnections
                .first(where: {$0.value === connection})?
                .key
        else { return }

        nearbyNetworkConnections[networkConnection] = nil
        connectionDelegate?.nearbyNetwork(self, didDisconnect: networkConnection)
    }

    public func nearbyNetworkListenerCannotConnect(_ sender: NearbyNetworkListener, connection: NWConnection) {
        guard
            let networkConnection = nearbyNetworkConnections
                .first(where: {$0.value === connection})?
                .key
        else { return }

        nearbyNetworkConnections[networkConnection] = nil
    }
}
