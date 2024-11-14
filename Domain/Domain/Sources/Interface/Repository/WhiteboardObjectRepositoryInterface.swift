//
//  WhiteboardObjectRepositoryInterface.swift
//  Domain
//
//  Created by 이동현 on 11/13/24.
//

public protocol WhiteboardObjectRepositoryInterface {
    /// 다른 사람이 보낸 화이트보드 오브젝트를 AsyncStream을 통해 전달하는 메서드
    /// - Returns: WhiteboardObject들이 담겨 있는 AsyncStream
    func whiteboardObjectAsyncStream() -> AsyncStream<WhiteboardObject>

    /// 다른 사람들에게 화이트보드 오브젝트를 전송하는 메서드.
    /// - Parameter whiteboardObject: 전송할 Whiteboard Object
    func send(whiteboardObject: WhiteboardObject)
}
