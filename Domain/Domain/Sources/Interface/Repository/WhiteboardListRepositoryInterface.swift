//
//  WhiteboardListRepositoryInterface.swift
//  Domain
//
//  Created by 최정인 on 1/14/25.
//

import Combine
import Foundation

public protocol WhiteboardListRepositoryInterface {
    var delegate: WhiteboardListRepositoryDelegate? { get set }

    /// 주변에 내 기기를 참여자의 아이콘 정보와 함께 화이트보드를 알립니다.
    /// - Parameters:
    ///   - myProfile: 나의 프로필
    ///   - paritipantIcons: 참여자 정보
    func startPublishing(myProfile: Profile, paritipantIcons: [ProfileIcon])

    /// 화이트보드 광고를 중지합니다.
    func stopPublishing()

    /// 화이트보드 탐색을 시작합니다.
    func startSearching()

    /// 화이트보드 탐색을 중지합니다.
    func stopSearching()

    /// 선택한 화이트보드와 연결을 시도합니다.
    /// - Parameter whiteboard: 연결할 화이트보드
    /// - Parameter myProfile: 내 프로필 정보
    /// - Returns: 연결 성공 여부
    func joinWhiteboard(whiteboard: Whiteboard, myProfile: Profile) async -> Bool
}

public protocol WhiteboardListRepositoryDelegate: AnyObject {
    /// 주변 화이트보드를 찾았을 때 실행됩니다.
    /// - Parameters:
    ///   - whiteboard: 탐색된 화이트보드
    func whiteboardListRepository(_ sender: WhiteboardListRepositoryInterface, didFind whiteboard: Whiteboard)

    /// 주변 화이트보드가 사라졌을 때 실행됩니다.
    /// - Parameters:
    ///   - whiteboard: 사라진 화이트보드
    func whiteboardListRepository(_ sender: WhiteboardListRepositoryInterface, didLost whiteboard: Whiteboard)
}
