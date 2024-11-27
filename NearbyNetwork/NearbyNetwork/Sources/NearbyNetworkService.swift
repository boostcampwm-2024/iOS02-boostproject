//
//  NearbyNetwork.swift
//  NearbyNetwork
//
//  Created by 최정인 on 11/7/24.
//

import Combine
import DataSource
import Foundation
import MultipeerConnectivity
import OSLog

public final class NearbyNetworkService: NSObject {
    public weak var connectionDelegate: NearbyNetworkConnectionDelegate?
    public let reciptDataPublisher: AnyPublisher<Data, Never>
    public let reciptURLPublisher: AnyPublisher<(url: URL, dataInfo: DataInformationDTO), Never>
    private let reciptDataSubject = PassthroughSubject<Data, Never>()
    private let reciptURLSubject = PassthroughSubject<(url: URL, dataInfo: DataInformationDTO), Never>()
    private let peerID: MCPeerID
    private let session: MCSession
    private var serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private var connectedPeers: [MCPeerID: NetworkConnection] = [:]
    private var foundPeers: [MCPeerID: NetworkConnection] = [:]

    private let logger = Logger()
    private var isHost = false
    private var requestInfo: [MCPeerID: Data] = [:]
    private let encoder = JSONEncoder()
    private let serialQueue = DispatchQueue(label: "NNS.serialQueue")

    public init(serviceName: String) {
        peerID = MCPeerID(displayName: UUID().uuidString)
        session = MCSession(peer: peerID)
        serviceAdvertiser =  MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: nil,
            serviceType: serviceName)
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceName)

        reciptDataPublisher = reciptDataSubject.eraseToAnyPublisher()
        reciptURLPublisher = reciptURLSubject.eraseToAnyPublisher()

        super.init()

        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
    }
}

// MARK: - NearbyNetworkInterface
extension NearbyNetworkService: NearbyNetworkInterface {
    public func startSearching() {
        serviceBrowser.startBrowsingForPeers()
    }

    public func stopSearching() {
        serviceBrowser.stopBrowsingForPeers()
    }

    public func restartSearching() {
        serialQueue.sync {
            serviceBrowser.stopBrowsingForPeers()
            foundPeers.removeAll()
            serviceBrowser.startBrowsingForPeers()
        }
    }

    public func startPublishing(with info: [String: String]) {
        isHost = true
        serviceAdvertiser.stopAdvertisingPeer()
        serviceAdvertiser =  MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: info,
            serviceType: serviceAdvertiser.serviceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
    }

    public func stopPublishing() {
        serviceAdvertiser.stopAdvertisingPeer()
    }

    public func disconnectAll() {
        session.disconnect()
    }

    public func joinConnection(connection: NetworkConnection, context: RequestedContext) throws {
        isHost = false

        let peerID = foundPeers
            .first { $0.value.id == connection.id }?
            .key
        // TODO: Error 수정
        guard let peerID else {
            throw NSError()
        }

        do {
            let encodedContext = try encoder.encode(context)
            serviceBrowser.invitePeer(
                peerID,
                to: session,
                withContext: encodedContext,
                timeout: 30)
        } catch {

        }
    }

    public func send(data: Data) {
        do {
            try session.send(
                data,
                toPeers: session.connectedPeers,
                with: .reliable)
        } catch {
            logger.log(level: .error, "데이터 전송 실패")
        }
    }

    public func send(fileURL: URL, info: DataSource.DataInformationDTO) async {
        let infoJsonData = try? JSONEncoder().encode(info)

        guard
            let infoJsonData,
            let infoJsonString = String(data: infoJsonData, encoding: .utf8)
        else { return }

        await withTaskGroup(of: Void.self) { taskGroup in
            session.connectedPeers.forEach { peer in
                taskGroup.addTask {
                    do {
                        try await self.session.sendResource(
                            at: fileURL,
                            withName: infoJsonString,
                            toPeer: peer)
                    } catch {
                        self.logger.log(level: .error, "\(peer)에게 file 데이터 전송 실패")
                    }
                }
            }
        }
    }
}

// MARK: - MCSessionDelegate
extension NearbyNetworkService: MCSessionDelegate {
    public func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        logger.log(level: .debug, "\(peerID.displayName) \(state.description)")

        serialQueue.sync { [weak self] in
            guard let self = self else { return }

            switch state {
            case .notConnected:
                guard let disconnectedPeer = connectedPeers[peerID] else { return }
                connectionDelegate?.nearbyNetwork(
                        self,
                        didDisconnect: disconnectedPeer,
                        isHost: isHost)
                connectedPeers[peerID] = nil
            case .connected:
                let connectedPeerInfo = foundPeers[peerID]?.info
                guard let uuid = UUID(uuidString: peerID.displayName) else { return }

                connectedPeers[peerID] = NetworkConnection(
                    id: uuid,
                    name: peerID.displayName,
                    info: connectedPeerInfo)

                guard let connection = connectedPeers[peerID] else { return }

                connectionDelegate?.nearbyNetwork(
                        self,
                        didConnect: connection,
                        with: requestInfo[peerID],
                        isHost: self.isHost)
            default:
                break
            }
        }
    }

    public func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        guard let connection = connectedPeers[peerID] else {
            logger.log(level: .error, "\(peerID.displayName)와 연결되어 있지 않음")
            return
        }
        reciptDataSubject.send(data)
    }

    public func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        logger.log(level: .error, "\(peerID.displayName)에게 스트림 데이터를 받음")
    }

    public func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        logger.log(level: .error, "\(peerID.displayName)로부터 데이터 수신을 시작함")
    }

    public func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: (any Error)?
    ) {
        guard
            let localURL,
            let jsonData = resourceName.data(using: .utf8),
            let dto = try? JSONDecoder().decode(DataInformationDTO.self, from: jsonData)
        else { return }

        reciptURLSubject.send((url: localURL, dataInfo: dto))
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension NearbyNetworkService: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        requestInfo[peerID] = context
        connectionDelegate?.nearbyNetwork(self, didReceive: { [weak self] isAccepted in
            invitationHandler(isAccepted, self?.session)
        })

    }

    public func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: any Error
    ) {
        logger.log(level: .error, "Advertising 실패 \(error.localizedDescription)")
        connectionDelegate?.nearbyNetworkCannotConnect(self)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension NearbyNetworkService: MCNearbyServiceBrowserDelegate {
    public func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        serialQueue.sync { [weak self] in
            guard let self else { return }
            guard let uuid = UUID(uuidString: peerID.displayName) else { return }

            let connection = NetworkConnection(
                id: uuid,
                name: peerID.displayName,
                info: info)

            foundPeers[peerID] = connection
            connectionDelegate?.nearbyNetwork(self, didFind: foundPeers
                .values
                .map { $0 }
                .sorted(by: { $0.name < $1.name }))
        }
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        serialQueue.sync { [weak self] in
            guard let self else { return }
            guard let lostPeer = foundPeers[peerID] else { return }

            foundPeers[peerID] = nil
            connectionDelegate?.nearbyNetwork(self, didLost: lostPeer)
        }
    }
}
