//
//  WhiteboardRepository.swift
//  Domain
//
//  Created by 최다경 on 11/12/24.
//
import Combine
import Foundation

public protocol WhiteboardRepositoryInterface {
    var delegate: WhiteboardRepositoryDelegate? { get set }

    /// 새로운 정보로 재게시합니다.
    /// - Parameter whiteboard: 게시할 화이트보드
    func republish(whiteboard: Whiteboard)

    /// 화이트보드와 연결을 끊습니다.
    func disconnectWhiteboard()

    /// 다른 사람들에게 화이트보드 오브젝트를 전송하는 메서드.
    /// - Parameters:
    ///   - whiteboardObject: 전송할 Whiteboard Object
    ///   - isDeleted: 오브젝트 삭제 여부
    /// - Returns: 전송 성공 여부
    func send(whiteboardObject: WhiteboardObject, isDeleted: Bool) async -> Bool

    /// 특정 사람에게 화이트보드 오브젝트 배열을 전송하는 메서드
    /// - Parameters:
    ///   - whiteboardObjects: 전송할 화이트보드 오브젝트들
    ///   - profile: 전송할 사람
    /// - Returns: 전송 성공 여부
    func send(whiteboardObjects: [WhiteboardObject], to profile: Profile) async -> Bool
}

public protocol WhiteboardRepositoryDelegate: AnyObject {
    /// 화이트보드에 새로운 참여자가 들어왔을때 실행됩니다.
    /// - Parameters:
    ///   - newPeer: 새로 참여한 참가자
    func whiteboardRepository(_ sender: WhiteboardRepositoryInterface, newPeer: Profile)

    /// 화이트보드에 참여자가 나갔을때 실행됩니다.
    /// - Parameters:
    ///   - lostPeer: 나간 참여자
    func whiteboardRepository(_ sender: WhiteboardRepositoryInterface, lostPeer: Profile)

    /// 화이트보드 오브젝트를 수신하면 실행됩니다.
    /// - Parameters:
    ///   - object: 추가되거나 수정된 화이트보드 오브젝트
    func whiteboardRepository(_ sender: WhiteboardRepositoryInterface, didReceive object: WhiteboardObject)

    /// 삭제된 화이트보드 오브젝트를 수신하면 실행됩니다.
    /// - Parameters:
    ///   - object: 삭제된 화이트보드 오브젝트
    func whiteboardRepository(_ sender: WhiteboardRepositoryInterface, didDelete object: WhiteboardObject)

    /// 사진을 수신하면 실행됩니다.
    /// - Parameters:
    ///   - photoID: 추가된 사진의 아이디
    func whiteboardRepository(
        _ sender: WhiteboardRepositoryInterface,
        didReceive photoID: UUID,
        savedURL: URL)
}
