//
//  WhiteboardObjectRepositoryInterface.swift
//  Domain
//
//  Created by 이동현 on 11/13/24.
//

public protocol WhiteboardObjectRepositoryInterface {
    /// WhiteboardObjectRepository의 delegate
    var delegate: WhiteboardObjectRepositoryDelegate? { get set }

    /// 다른 사람들에게 화이트보드 오브젝트를 전송하는 메서드.
    /// - Parameter whiteboardObject: 전송할 Whiteboard Object
    func send(whiteboardObject: WhiteboardObject) async

    /// 텍스트 오브젝트를 삭제합니다.
    /// - Parameter textObject: 삭제할 Whiteboard Object
    func delete(whiteboardObject: WhiteboardObject)
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
}
