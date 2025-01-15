//
//  NearbyNetworkTests.swift
//  NearbyNetworkTests
//
//  Created by 이동현 on 12/31/24.
//

import DataSource
import NearbyNetwork
import Network
import XCTest

final class NearbyNetworkTests: XCTestCase {
    var nearbyNetworkService: RefactoredNearbyNetworkService?
    var mockBrowser: NWBrowser?
    var mockListener: NWListener?
    let serviceName = "airplain"
    let serviceType = "_airplain._tcp"

    override func setUpWithError() throws {
        nearbyNetworkService = RefactoredNearbyNetworkService(
            myPeerID: UUID(),
            serviceName: serviceName,
            serviceType: serviceType)

        mockBrowser = NWBrowser(
            for: .bonjourWithTXTRecord(type: serviceType, domain: nil),
            using: .tcp)

        mockListener = try? NWListener(using: .tcp)
        mockListener?.newConnectionHandler = { _ in }
    }

    override func tearDownWithError() throws {
        nearbyNetworkService = nil
    }

    func testAdvertisingSuccess() {
        // 준비
        let expectedHostName = "host"
        let expectedConnectedPeerInfo = ["1", "2", "3"]
        let browserQueue = DispatchQueue.global()
        let browsingExpectation = XCTestExpectation(description: "검색 성공 여부")
        var browsedHostName: String?
        var browsedPeerInfo: String?
        guard let mockBrowser else {
            XCTFail("mockBrowser가 초기화되지 않았습니다.")
            return
        }

        // 실행
        XCTAssertNotNil(nearbyNetworkService)
        nearbyNetworkService?.startPublishing(
            with: expectedHostName,
            connectedPeerInfo: expectedConnectedPeerInfo)

        mockBrowser.start(queue: browserQueue)
        mockBrowser.browseResultsChangedHandler = { results, _ in
            for result in results {
                switch result.metadata {
                case .bonjour(let foundedPeerData):
                    browsedHostName = foundedPeerData.dictionary[NearbyNetworkKey.host.rawValue]
                    browsedPeerInfo = foundedPeerData.dictionary[NearbyNetworkKey.connectedPeerInfo.rawValue]
                    browsingExpectation.fulfill()
                default:
                    break
                }
                break
            }
        }
        wait(for: [browsingExpectation], timeout: 3)

        // 검증
        guard
            let browsedHostName,
            let browsedPeerInfo
        else {
            XCTFail("browsedHostName, browsedPeerInfo가 정상적으로 초기화되지 않았습니다.")
            return
        }

        XCTAssertEqual(expectedHostName, browsedHostName)
        XCTAssertEqual(expectedConnectedPeerInfo.joined(separator: ","), browsedPeerInfo)
    }

    func testBrowsingSuccess() {
        // 준비
        let expectedHostName = "host"
        let expectedConnectedPeerInfo = ["1", "2", "3"]
        let txtRecord = NWTXTRecord([
            NearbyNetworkKey.host.rawValue: expectedHostName,
            NearbyNetworkKey.connectedPeerInfo.rawValue: expectedConnectedPeerInfo.joined(separator: ",")
        ])

        guard let mockListener else {
            XCTFail("advertiser 생성 실패")
            return
        }
        let advertiserQueue = DispatchQueue.global()
        let advertisingExpectation = XCTestExpectation(description: "광고 성공 여부")
        var advertisingHostName: String?
        var advertisingPeerInfo: [String]?
        let foundPeerHandler: ([RefactoredNetworkConnection]) -> Void = { connection in
            advertisingHostName = connection.first!.name
            advertisingPeerInfo = connection.first!.connectedPeerInfo
            advertisingExpectation.fulfill()
        }
        nearbyNetworkService?.foundPeerHandler = foundPeerHandler
        mockListener.service = NWListener.Service(
            name: serviceName,
            type: serviceType,
            txtRecord: txtRecord)

        // 실행
        mockListener.start(queue: advertiserQueue)
        nearbyNetworkService?.startSearching()
        wait(for: [advertisingExpectation], timeout: 3)

        // 검증
        guard
            let advertisingHostName,
            let advertisingPeerInfo
        else {
            XCTFail("advertisingHostName, advertisingPeerInfo가 정상적으로 초기화되지 않았습니다.")
            return
        }

        XCTAssertEqual(expectedHostName, advertisingHostName)
        XCTAssertEqual(expectedConnectedPeerInfo, advertisingPeerInfo)
    }
}
