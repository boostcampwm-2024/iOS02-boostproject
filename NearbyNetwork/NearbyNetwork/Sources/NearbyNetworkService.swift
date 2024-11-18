//
//  NearbyNetwork.swift
//  NearbyNetwork
//
//  Created by 최정인 on 11/7/24.
//

import DataSource
import Foundation
import MultipeerConnectivity
import OSLog

public final class NearbyNetworkService: NSObject {
    public weak var delegate: NearbyNetworkDelegate?
    private let peerID: MCPeerID
    private let session: MCSession
    private var serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private var connectedPeers: [MCPeerID: NetworkConnection] = [:]
    private var foundPeers: [MCPeerID: NetworkConnection] = [:] {
        didSet {
            let foundPeers: [NetworkConnection] = foundPeers.values.map { $0 }
            delegate?.nearbyNetwork(self, didFind: foundPeers)
        }
    }
    private let logger = Logger()

    public init(profileName: String, serviceName: String) {
        peerID = MCPeerID(displayName: profileName)
        session = MCSession(peer: peerID)
        serviceAdvertiser =  MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: nil,
            serviceType: serviceName)
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceName)

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

    public func startPublishing() {
        serviceAdvertiser.startAdvertisingPeer()
    }

    public func startPublishing(with info: [String: String]) {
        Task {
            serviceAdvertiser.stopAdvertisingPeer()
            try? await Task.sleep(nanoseconds: 500_000_000)
            serviceAdvertiser =  MCNearbyServiceAdvertiser(
                peer: peerID,
                discoveryInfo: info,
                serviceType: serviceAdvertiser.serviceType)
            serviceAdvertiser.startAdvertisingPeer()
        }
    }

    public func stopPublishing() {
        serviceAdvertiser.stopAdvertisingPeer()
    }

    public func joinConnection(connection: NetworkConnection) throws {
        let peerID = foundPeers
            .first { $0.value == connection }?
            .key
        // TODO: Error 수정
        guard let peerID else {
            throw NSError()
        }
        serviceBrowser.invitePeer(
            peerID,
            to: session,
            withContext: nil,
            timeout: 30)
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
}

// MARK: - MCSessionDelegate
extension NearbyNetworkService: MCSessionDelegate {
    public func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        logger.log(level: .debug, "\(peerID.displayName) \(state.description)")

        switch state {
        case .notConnected:
            connectedPeers[peerID] = nil
        case .connected:
            connectedPeers[peerID] = NetworkConnection(id: UUID(), name: peerID.displayName)
        default:
            break
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
        delegate?.nearbyNetwork(self, didReceive: data, from: connection)
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
        logger.log(level: .error, "\(peerID.displayName)로부터 데이터 수신을 완료함")
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
        delegate?.nearbyNetwork(self, didReceive: { [weak self] isAccepted in
            invitationHandler(isAccepted, self?.session)
        })
    }

    public func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: any Error
    ) {
        logger.log(level: .error, "Advertising 실패 \(error.localizedDescription)")
        delegate?.nearbyNetworkCannotConnect(self)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension NearbyNetworkService: MCNearbyServiceBrowserDelegate {
    public func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        let connection = NetworkConnection(id: UUID(), name: peerID.displayName)
        foundPeers[peerID] = connection
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        foundPeers[peerID] = nil
    }
}

// MARK: - MCSessionState
extension MCSessionState {
    var description: String {
        switch self {
        case .notConnected:
            return "연결 끊김"
        case .connecting:
            return "연결 중"
        case .connected:
            return "연결 됨"
        @unknown default:
            return "알 수 없음"
        }
    }
}
