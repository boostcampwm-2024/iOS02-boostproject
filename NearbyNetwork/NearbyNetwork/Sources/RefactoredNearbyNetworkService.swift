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
    private let logger: Logger
    public var foundPeerHandler: ((_ hostName: String, _ connectedPeerInfo: [String]) -> Void)?

    public init(serviceName: String, serviceType: String) {
        peerID = UUID()
        logger = Logger()
        nearbyNetworkListener = NearbyNetworkListener(
            serviceName: serviceName,
            serviceType: serviceType)
        nearbyNetworkBrowser = NearbyNetworkBrowser(serviceType: serviceType)
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
        hostName: String,
        connectedPeerInfo: [String]
    ) {
        guard let foundPeerHandler else { return }
        foundPeerHandler(hostName, connectedPeerInfo)
    }
}
