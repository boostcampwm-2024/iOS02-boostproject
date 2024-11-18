//
//  WhiteboardRepository.swift
//  Domain
//
//  Created by 최다경 on 11/12/24.
//

public protocol WhiteboardRepositoryInterface {
    var delegate: WhiteboardRepositoryDelegate? { get set }

    /// 화이트보드를 주변에 알립니다.
    func startPublishing()

    /// 주변 화이트보드를 탐색합니다.
    func startSearching()
}

public protocol WhiteboardRepositoryDelegate: AnyObject {
    /// 주변 화이트보드를 찾았을 때 실행됩니다.
    /// - Parameters:
    ///   - whiteboards: 탐색된 화이트보드 배열
    func whiteboard(_ sender: WhiteboardRepositoryInterface, didFind whiteboards: [Whiteboard])
}
