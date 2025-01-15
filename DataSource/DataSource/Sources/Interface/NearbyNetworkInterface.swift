//
//  NearbyNetworkInterface.swift
//  DataSource
//
//  Created by 최정인 on 11/7/24.
//

import Combine
import Foundation

public protocol NearbyNetworkInterface {
    var reciptDataPublisher: AnyPublisher<AirplaINDataDTO, Never> { get }
    var searchingDelegate: NearbyNetworkSearchingDelegate? { get set }
    var connectionDelegate: NearbyNetworkConnectionDelegate? { get set }

    /// 주변 기기 검색을 중지합니다.
    func stopSearching()

    /// 주변 기기를 검색합니다.
    func startSearching()

    /// 주변에 내 기기를 정보와 함께 알립니다.
    /// - Parameters:
    ///   - hostName: 호스트의 이름
    ///   - connectedPeerInfo: 연결된 기기들의 정보
    func startPublishing(with hostName: String, connectedPeerInfo: [String])

    /// 주변에 내 기기 알리는 것을 중지합니다.
    func stopPublishing()

    /// 연결된 모든 피어와 연결을 끊습니다.
    func disconnectAll()

    /// 주변 기기와 연결을 시도합니다.
    /// - Parameters:
    ///   - connection: 연결할 기기
    ///   - myConnectionInfo: 내 정보
    /// - Returns: 연결 요청 성공 여부
    func joinConnection(
        connection: NetworkConnection,
        myConnectionInfo: RequestedContext) async -> Bool

    /// 연결된 기기들에게 데이터를 송신합니다.
    /// - Parameter data: 송신할 데이터
    /// - Returns: 전송 성공 여부
    func send(data: AirplaINDataDTO) async -> Bool

    /// 특정 기기에게 데이터를 전송합니다.
    /// - Parameters:
    ///   - data: 송신할 데이터
    ///   - connection: 전송할 기기 연결 정보
    /// - Returns: 전송 성공 여부
    func send(data: AirplaINDataDTO, to connection: NetworkConnection) async -> Bool
}

public protocol NearbyNetworkSearchingDelegate: AnyObject {
    /// 주변 기기가 검색됐을 때 실행됩니다.
    /// - Parameters:
    ///   - connections: 검색된 기기
    func nearbyNetwork(_ sender: NearbyNetworkInterface, didFind connection: NetworkConnection)

    /// 검색된 기기가 사라졌을 때 실행됩니다.
    /// - Parameters:
    ///   - connection: 사라진 기기
    func nearbyNetwork(_ sender: NearbyNetworkInterface, didLost connection: NetworkConnection)
}

public protocol NearbyNetworkConnectionDelegate: AnyObject {
    /// 주변 기기와 연결에 성공했을 때 실행됩니다.
    /// - Parameters:
    ///   - didConnect: 연결된 peer
    func nearbyNetwork(_ sender: NearbyNetworkInterface, didConnect connection: NetworkConnection)

    /// 연결됐던 기기와 연결이 끊어졌을 때 실행됩니다.
    /// - Parameters:
    ///   - connection: 연결이 끊긴 기기
    func nearbyNetwork(_ sender: NearbyNetworkInterface, didDisconnect connection: NetworkConnection)
}
