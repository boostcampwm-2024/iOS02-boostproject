//
//  WhiteboardUseCaseInterface.swift
//  Domain
//
//  Created by 최다경 on 11/13/24.
//

import Combine

public protocol WhiteboardUseCaseInterface {
    var whiteboardListPublisher: AnyPublisher<[Whiteboard], Never> { get }

    /// 화이트보드를 생성합니다.
    /// - Parameter nickname: 유저 닉네임(화이트보드의 이름으로 사용)
    func createWhiteboard(nickname: String) -> Whiteboard

    /// 화이트보드를 주변에 알립니다. 
    func startPublishingWhiteboard()

    /// 주변 화이트보드를 탐색합니다. 
    func startSearchingWhiteboard()
}
