//
//  WhiteObjectSendUseCaseInterface.swift
//  Domain
//
//  Created by 박승찬 on 11/14/24.
//

public protocol WhiteObjectSendUseCaseInterface {
    /// 화이트보드 오브젝트를 전송하는 메서드
    /// - Parameter WhiteboardObject: 전송할 화이트보드 오브젝트
    func send(whiteboardObject: WhiteboardObject)
}
