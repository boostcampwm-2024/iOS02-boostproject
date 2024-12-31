//
//  NearbyNetworkTests.swift
//  NearbyNetworkTests
//
//  Created by 이동현 on 12/31/24.
//

import NearbyNetwork
import Network
import XCTest

final class NearbyNetworkTests: XCTestCase {
    var nearbyNetworkService: RefactoredNearbyNetworkService?

    override func setUpWithError() throws {
        nearbyNetworkService = RefactoredNearbyNetworkService(
            serviceName: "airplain",
            serviceType: "_airplain._tcp")
    }

    override func tearDownWithError() throws {
        nearbyNetworkService = nil
    }

    func testAdvertisingSuccess() {
        // 준비
        let expectedHostName = "host"
        let expectedConnectedPeerInfo = ["1", "2", "3"]
        let serviceType = "_airplain._tcp"
        let browserQueue = DispatchQueue.global()
        let browser = NWBrowser(
            for: .bonjourWithTXTRecord(type: serviceType, domain: nil),
            using: .tcp)
        let browsingExpectation = XCTestExpectation(description: "검색 성공 여부")
        var browsedHostName: String?
        var browsedPeerInfo: String?

        // 실행
        XCTAssertNotNil(nearbyNetworkService)
        nearbyNetworkService?.startPublishing(
            with: expectedHostName,
            connectedPeerInfo: expectedConnectedPeerInfo)

        browser.start(queue: browserQueue)
        browser.browseResultsChangedHandler = { results, _ in
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
        guard let advertiser = try? NWListener(using: .tcp) else {
            XCTFail("advertiser 생성 실패")
            return
        }
        let advertiserQueue = DispatchQueue.global()
        let advertisingExpectation = XCTestExpectation(description: "광고 성공 여부")
        var advertisingHostName: String?
        var advertisingPeerInfo: [String]?
        let foundPeerHandler: (String, [String]) -> Void = { hostName, connectedPeerInfo in
            advertisingHostName = hostName
            advertisingPeerInfo = connectedPeerInfo
            advertisingExpectation.fulfill()
        }
        nearbyNetworkService?.foundPeerHandler = foundPeerHandler
        advertiser.newConnectionHandler = { _ in }
        advertiser.service = NWListener.Service(
            name: "airplain",
            type: "_airplain._tcp",
            txtRecord: txtRecord)

        // 실행
        advertiser.start(queue: advertiserQueue)
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
