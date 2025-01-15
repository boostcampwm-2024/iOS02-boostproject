//
//  WhiteboardListUseCaseInterface.swift
//  Domain
//
//  Created by 최다경 on 11/13/24.
//

import Combine

public protocol WhiteboardListUseCaseInterface {
    var whiteboardListPublisher: AnyPublisher<[Whiteboard], Never> { get }

    /// 화이트보드를 생성합니다.
    func createWhiteboard() -> Whiteboard

    /// 주변에 내 기기를 정보와 함께 알립니다.
    func startPublishingWhiteboard()

    /// 선택한 화이트보드와 연결을 시도합니다.
    /// - Parameter whiteboard: 연결할 화이트보드
    /// - Returns: 연결 성공 여부
    func joinWhiteboard(whiteboard: Whiteboard) async -> Bool

    /// 주변 화이트보드를 탐색합니다.
    func startSearchingWhiteboards()
}
