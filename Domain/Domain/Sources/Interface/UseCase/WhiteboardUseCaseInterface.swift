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
    func createWhiteboard() -> Whiteboard

    /// 주변에 내 기기를 정보와 함께 알립니다.
    func startPublishingWhiteboard()

    /// 주변 화이트보드를 탐색합니다. 
    func startSearchingWhiteboard()

    /// 화이트보드 탐색을 중지합니다.
    func stopSearchingWhiteboard()
}
