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

// TODO: - 추후 기능 동작 확인 후 NearbyNetworkService 대체
final class RefactoredNearbyNetworkService {
    var connectionDelegate: NearbyNetworkConnectionDelegate? = nil
    private let peerID: UUID
    private let nwListener: NWListener
    private let networkQueue: DispatchQueue

    public init(serviceName: String) throws {
        peerID = UUID()

        do {
            nwListener = try NWListener(using: .tcp)
            networkQueue = DispatchQueue.global()
        } catch {
            throw NSError() // 에러는 추후 정의
        }
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

    func stopSearching() {

    }

    func startSearching() {

    }

    func startPublishing(with info: [String: String]) {
        // TODO: - will be deprecated
    }

    func startPublishing(with hostName: String, connectedPeerInfo: [String]) {
        let networkConnection = RefactoredNetworkConnection(
            id: peerID,
            name: hostName,
            connectedPeerInfo: connectedPeerInfo)
        let serviceData = try? JSONEncoder().encode(networkConnection)

        nwListener.service? = NWListener.Service(type: "_airplain._tcp", txtRecord: serviceData)
        nwListener.start(queue: networkQueue)
    }

    func stopPublishing() {

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
