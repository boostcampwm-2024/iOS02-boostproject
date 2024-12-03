//
//  WhiteboardObjectSetInterface.swift
//  Domain
//
//  Created by 이동현 on 11/26/24.
//

import Foundation

public protocol WhiteboardObjectSetInterface {

    /// 집합에 오브젝트가 있는지 확인합니다.
    /// - Parameter object: 확인할 오브젝트
    /// - Returns: 오브젝트 존재 여부
    func contains(object: WhiteboardObject) async -> Bool

    /// 집합에 오브젝트를 추가합니다.
    /// - Parameter object: 추가할 오브젝트
    func insert(object: WhiteboardObject) async

    /// 집합에서 오브젝트를 삭제합니다.
    /// - Parameter object: 삭제할 오브젝트
    func remove(object: WhiteboardObject) async

    /// 모든 화이트보드 오브젝트들을 삭제합니다.
    func removeAll() async

    /// 집합에 있는 오브젝트를 업데이트 합니다.
    /// - Parameter object: 업데이트할 오브젝트
    func update(object: WhiteboardObject) async

    /// ID로 집합에있는 오브젝트를 가져옵니다.
    /// - Parameter id: 가져올 오브젝트의 ID
    /// - Returns: 오브젝트
    func fetchObjectByID(id: UUID) async -> WhiteboardObject?

    /// 모든 화이트보드 오브젝트들을 가져옵니다.
    /// - Returns: 화이트보드 오브젝트 배열
    func fetchAll() async -> [WhiteboardObject]
}
