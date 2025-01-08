//
//  RefactoredNearbyNetworkService.swift
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
public final class RefactoredNearbyNetworkService {
    public var connectionDelegate: NearbyNetworkConnectionDelegate? = nil
    public var foundPeerHandler: ((_ networkConnections: [RefactoredNetworkConnection]) -> Void)?
    private let serviceName: String
    private let serviceType: String
    private let peerID: UUID
    private let nearbyNetworkListener: NearbyNetworkListener
    private let nearbyNetworkBrowser: NearbyNetworkBrowser
    private let nearbyNetworkServiceQueue: DispatchQueue
    private let logger: Logger
    private var nearbyNetworkConnections: [RefactoredNetworkConnection: NWConnection]
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
        nearbyNetworkListener = NearbyNetworkListener(
            peerID: peerID,
            serviceName: serviceName,
            serviceType: serviceType)
        nearbyNetworkBrowser = NearbyNetworkBrowser(serviceType: serviceType)
        nearbyNetworkConnections = [:]
        jsonEncoder = JSONEncoder()
        jsonDecoder = JSONDecoder()
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

        let networkConnection = RefactoredNetworkConnection(
            id: connectionInfo.peerID,
            name: connectionInfo.nickname,
            connectedPeerInfo: [connectionInfo.participant])
        self.nearbyNetworkConnections[networkConnection] = connection
        self.connectionDelegate?.nearbyNetwork(self, didConnect: networkConnection)
        self.logger.log(level: .debug, "\(networkConnection): 데이터 수신")
    }

    private func handleReceivedData(data: Data?, connection: NWConnection) {
        self.logger.log(level: .error, "\(connection.debugDescription): 데이터 수신")
    }
}

// MARK: - NearbyNetworkInterface 메서드 구현
extension RefactoredNearbyNetworkService: NearbyNetworkInterface {
    public var reciptDataPublisher: AnyPublisher<Data, Never> {
        return Just<Data>(Data()).eraseToAnyPublisher()
    }

    public var reciptURLPublisher: AnyPublisher<(url: URL, dataInfo: DataInformationDTO), Never> {
        // TODO: - will be deprecated
        guard let url = URL(string: "https://naver.com") else { fatalError() }
        let dataInfo = DataInformationDTO(
            id: UUID(),
            type: .chat,
            isDeleted: true)
        return Just<(url: URL, dataInfo: DataInformationDTO)>((url: url, dataInfo: dataInfo))
            .eraseToAnyPublisher()
    }

    public func startSearching() {
        nearbyNetworkBrowser.startSearching()
    }

    public func stopSearching() {
        nearbyNetworkBrowser.stopSearching()
    }

    public func startPublishing(with info: [String: String]) {
        // TODO: - will be deprecated
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

    }

    public func joinConnection(connection: NetworkConnection, context: RequestedContext) throws {
    }

    public func joinConnection(
        connection: RefactoredNetworkConnection,
        myConnectionInfo: RequestedContext
    ) -> Result<Bool, Never> {
        guard let endpoint = nearbyNetworkBrowser.fetchFoundConnection(networkConnection: connection)
        else { return .success(false) }

        let option = NWProtocolFramer.Options(definition: NearbyNetworkProtocol.definition)
        let parameter = NWParameters.tcp
        parameter.defaultProtocolStack
            .applicationProtocols
            .insert(option, at: 0)

        let nwConnection = NWConnection(to: endpoint, using: parameter)
        nwConnection.stateUpdateHandler = { [weak self] state in
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
        nwConnection.start(queue: nearbyNetworkServiceQueue)
        return .success(true)
    }

    public func send(data: Data) {

    }

    public func send(fileURL: URL, info: DataInformationDTO) async {
        // TODO: - will be deprecated
    }

    public func send(fileURL: URL, info: DataInformationDTO, to connection: NetworkConnection) async {
        // TODO: - will be deprecated
    }
}

// MARK: - NearbyNetworkBrowserDelegate
extension RefactoredNearbyNetworkService: NearbyNetworkBrowserDelegate {
    public func nearbyNetworkBrowserDidFindPeer(
        _ sender: NearbyNetworkBrowser,
        foundPeers: [RefactoredNetworkConnection]
    ) {
        guard let foundPeerHandler else { return }
        foundPeerHandler(foundPeers)
    }
}

extension RefactoredNearbyNetworkService: NearbyNetworkListenerDelegate {
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
        connectionDelegate?.nearbyNetworkCannotConnect(self)

        guard
            let networkConnection = nearbyNetworkConnections
                .first(where: {$0.value === connection})?
                .key
        else { return }

        nearbyNetworkConnections[networkConnection] = nil
    }
}
