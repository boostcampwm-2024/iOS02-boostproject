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
final class RefactoredNearbyNetworkService {
    var connectionDelegate: NearbyNetworkConnectionDelegate? = nil
    private let serviceName: String
    private let serviceType: String
    private let peerID: UUID
    private let nearbyNetworkListener: NearbyNetworkListener
    private let nearbyNetworkBrowser: NearbyNetworkBrowser
    private let logger: Logger

    public init(serviceName: String, serviceType: String) throws {
        peerID = UUID()
        logger = Logger()
        nearbyNetworkListener = NearbyNetworkListener(
            serviceName: serviceName,
            serviceType: serviceType)
        nearbyNetworkBrowser = NearbyNetworkBrowser(serviceType: serviceType)
        self.serviceName = serviceName
        self.serviceType = serviceType
    }
}

extension RefactoredNearbyNetworkService: NearbyNetworkInterface {
    var reciptDataPublisher: AnyPublisher<Data, Never> {
        return Just<Data>(Data()).eraseToAnyPublisher()
    }

    var reciptURLPublisher: AnyPublisher<(url: URL, dataInfo: DataInformationDTO), Never> {
        // TODO: - will be deprecated
        guard let url = URL(string: "https://naver.com") else { fatalError() }
        let dataInfo = DataInformationDTO(
            id: UUID(),
            type: .chat,
            isDeleted: true)
        return Just<(url: URL, dataInfo: DataInformationDTO)>((url: url, dataInfo: dataInfo))
            .eraseToAnyPublisher()
    }

    func startSearching() {
        nearbyNetworkBrowser.startSearching()
    }

    func stopSearching() {
        nearbyNetworkBrowser.stopSearching()
    }

    func startPublishing(with info: [String: String]) {
        // TODO: - will be deprecated
    }

    func startPublishing(with hostName: String, connectedPeerInfo: [String]) {
        nearbyNetworkListener.startPublishing(
            hostName: hostName,
            connectedPeerInfo: connectedPeerInfo)
    }

    func stopPublishing() {
        nearbyNetworkListener.stopPublishing()
    }

    func disconnectAll() {

    }

    func joinConnection(connection: NetworkConnection, context: RequestedContext) throws {

    }

    func send(data: Data) {

    }

    func send(fileURL: URL, info: DataInformationDTO) async {
        // TODO: - will be deprecated
    }

    func send(fileURL: URL, info: DataInformationDTO, to connection: NetworkConnection) async {
        // TODO: - will be deprecated
    }
}
