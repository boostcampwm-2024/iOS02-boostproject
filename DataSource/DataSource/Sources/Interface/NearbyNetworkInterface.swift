//
//  NearbyNetworkInterface.swift
//  DataSource
//
//  Created by 최정인 on 11/7/24.
//

import Foundation

public protocol NearbyNetworkInterface {
    var delegate: NearbyNetworkDelegate? { get set }

    /// 주변 기기를 검색합니다.
    func startSearching()

    /// 주변 기기 검색을 중지합니다.
    func stopSearching()

    /// 주변에 내 기기를 알립니다.
    func startPublishing()

    /// 주변에 내 기기를 정보와 함께 알립니다.
    /// - Parameter data: 담을 정보
    func startPublishing(with info: [String: String])

    /// 주변에 내 기기 알리는 것을 중지합니다.
    func stopPublishing()

    /// 주변 기기와 연결을 시도합니다.
    /// - Parameter connection: 연결할 기기
    func joinConnection(connection: NetworkConnection) throws

    /// 연결된 기기들에게 데이터를 송신합니다.
    /// - Parameter data: 송신할 데이터
    func send(data: Data)

    /// 연결된 기기들에게 파일을 송신합니다.
    /// - Parameters:
    ///   - fileURL: 파일의 URL
    ///   - info: 파일에 대한 정보
    func send(fileURL: URL, info: DataInformationDTO)
}

public protocol NearbyNetworkDelegate: AnyObject {
    /// 데이터를 수신했을 때 실행됩니다.
    /// - Parameters:
    ///   - data: 수신된 데이터
    ///   - connection: 데이터를 송신한 기기
    func nearbyNetwork(_ sender: NearbyNetworkInterface, didReceive data: Data, from connection: NetworkConnection)


    /// 파일을 수신했을 때 실행됩니다.
    /// - Parameters:
    ///   - URL: 수신한 파일의 URL
    ///   - Connection: 데이터를 송신한 기기
    ///   - info: 파일에 대한 정보
    func nearbyNetwork(
        _ sender: NearbyNetworkInterface,
        didReceive URL: URL,
        from Connection: NetworkConnection,
        info: DataInformationDTO)

    /// 주변 기기에게 연결 요청을 받았을 때 실행됩니다.
    /// - Parameters:
    ///   - connectionHandler: 연결 요청 처리 Handler
    func nearbyNetwork(_ sender: NearbyNetworkInterface, didReceive connectionHandler: @escaping (Bool) -> Void)

    /// 주변 기기가 검색됐을 때 실행됩니다.
    /// - Parameters:
    ///   - connections: 검색된 기기들
    func nearbyNetwork(_ sender: NearbyNetworkInterface, didFind connections: [NetworkConnection])

    /// 주변 기기와의 연결에 실패했을 때 실행됩니다.
    func nearbyNetworkCannotConnect(_ sender: NearbyNetworkInterface)
}
