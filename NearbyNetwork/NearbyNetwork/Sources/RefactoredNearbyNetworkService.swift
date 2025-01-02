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
    private let serviceName: String
    private let serviceType: String
    private let peerID: UUID
    private let nearbyNetworkListener: NearbyNetworkListener
    private let nearbyNetworkBrowser: NearbyNetworkBrowser
    private var nearbyNetworkConnections: [RefactoredNetworkConnection: NWConnection]
    private let nearbyNetworkServiceQueue: DispatchQueue
    private let logger: Logger
    public var foundPeerHandler: ((_ networkConnection: RefactoredNetworkConnection) -> Void)?

    public init(serviceName: String, serviceType: String) {
        peerID = UUID()
        nearbyNetworkServiceQueue = DispatchQueue.global()
        logger = Logger()
        nearbyNetworkListener = NearbyNetworkListener(
            peerID: peerID,
            serviceName: serviceName,
            serviceType: serviceType)
        nearbyNetworkBrowser = NearbyNetworkBrowser(serviceType: serviceType)
        nearbyNetworkConnections = [:]
        self.serviceName = serviceName
        self.serviceType = serviceType
        nearbyNetworkBrowser.delegate = self
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
        myConnectionInfo: RequestedContext) -> Result<Bool, Never> {
            guard let endpoint = nearbyNetworkBrowser.fetchFoundConnection(networkConnection: connection)
            else { return .success(false) }

            let nwConnection = NWConnection(to: endpoint, using: .tcp)
            nwConnection.stateUpdateHandler = { [weak self] state in
                switch state {
                case .ready:
                    self?.logger.log(level: .debug, "\(connection)와 연결되었습니다.")
                    self?.nearbyNetworkConnections[connection] = nwConnection
                case .failed, .cancelled:
                    self?.logger.log(level: .debug, "\(connection)와 연결이 끊어졌습니다.")
                    self?.nearbyNetworkConnections[connection] = nil
                default:
                    self?.logger.log(level: .debug, "\(connection)와 연결 설정 중입니다.")
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
        foundPeer: RefactoredNetworkConnection
    ) {
        guard let foundPeerHandler else { return }
        foundPeerHandler(foundPeer)
    }
}
