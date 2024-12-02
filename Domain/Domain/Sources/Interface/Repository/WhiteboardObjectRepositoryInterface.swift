//
//  WhiteboardObjectRepositoryInterface.swift
//  Domain
//
//  Created by 이동현 on 11/13/24.
//
import Foundation

public protocol WhiteboardObjectRepositoryInterface {
    /// WhiteboardObjectRepository의 delegate
    var delegate: WhiteboardObjectRepositoryDelegate? { get set }

    /// 특정 사람에게 화이트보드 오브젝트를 전송하는 메서드
    /// - Parameters:
    ///   - whiteboardObject: 전송할 화이트보드 오브젝트
    ///   - isDeleted: 오브젝트 삭제 여부
    ///   - profile: 전송할 사람
    func send(
        whiteboardObject: WhiteboardObject,
        isDeleted: Bool,
        to profile: Profile) async

    /// 다른 사람들에게 화이트보드 오브젝트를 전송하는 메서드.
    /// - Parameter whiteboardObject: 전송할 Whiteboard Object
    func send(whiteboardObject: WhiteboardObject, isDeleted: Bool) async

    /// 특정 사람에게 화이트보드 오브젝트 배열을 전송하는 메서드
    /// - Parameters:
    ///   - whiteboardObjects: 전송할 화이트보드 오브젝트들
    ///   - isDeleted: 오브젝트 삭제 여부
    ///   - profile: 전송할 사람
    func send(
        whiteboardObjects: [WhiteboardObject],
        isDeleted: Bool,
        to profile: Profile) async
}

public protocol WhiteboardObjectRepositoryDelegate: AnyObject {
    /// 화이트보드 오브젝트를 수신하면 실행됩니다.
    /// - Parameters:
    ///   - object: 추가되거나 수정된 화이트보드 오브젝트
    func whiteboardObjectRepository(_ sender: WhiteboardObjectRepositoryInterface, didReceive object: WhiteboardObject)

    /// 삭제된 화이트보드 오브젝트를 수신하면 실행됩니다.
    /// - Parameters:
    ///   - object: 삭제된 화이트보드 오브젝트
    func whiteboardObjectRepository(_ sender: WhiteboardObjectRepositoryInterface, didDelete object: WhiteboardObject)

    /// 사진을 수신하면 실행됩니다.
    /// - Parameters:
    ///   - photoID: 추가된 사진의 아이디
    func whiteboardObjectRepository(
        _ sender: WhiteboardObjectRepositoryInterface,
        didReceive photoID: UUID,
        savedURL: URL)
}
