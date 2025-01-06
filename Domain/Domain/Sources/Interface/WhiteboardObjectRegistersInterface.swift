//
//  WhiteboardObjectRegistersInterface.swift
//  Domain
//
//  Created by 박승찬 on 1/6/25.
//

import Foundation

public protocol WhiteboardObjectRegistersInterface {
    /// 집합에 레지스터가 있는지 확인합니다.
    /// - Parameter register: 확인할 레지스터
    /// - Returns: 오브젝트 존재 여부
    func contains(register: LWWRegister) async -> Bool

    /// 집합에 레지스터를 추가합니다.
    /// - Parameter object: 추가할 레지스터
    func insert(register: LWWRegister) async

    /// 집합에서 레지스터를 삭제합니다.
    /// - Parameter register: 삭제할 레지스터
    func remove(register: LWWRegister) async

    /// 모든 화이트보드 오브젝트 레지스터들을 삭제합니다.
    func removeAll() async

    /// 집합에 있는 레지스터를 업데이트 합니다.
    /// - Parameter register: 업데이트할 레지스터
    func update(register: LWWRegister) async

    /// ID로 집합에있는 레지스터를 가져옵니다.
    /// - Parameter id: 가져올 레지스터의 오브젝트 ID
    /// - Returns: 레지스터
    func fetchObjectByID(id: UUID) async -> LWWRegister?

    /// 모든 화이트보드 오브젝트 레지스터들을 가져옵니다.
    /// - Returns: 화이트보드 레지스터 배열
    func fetchAll() async -> [LWWRegister]
}
