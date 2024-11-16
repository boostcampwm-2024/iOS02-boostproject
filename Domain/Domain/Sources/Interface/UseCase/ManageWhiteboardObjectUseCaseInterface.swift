//
//  ManageWhiteboardObjectUseCaseInterface.swift
//  Domain
//
//  Created by 이동현 on 11/16/24.
//
import Combine

public protocol ManageWhiteboardObjectUseCaseInterface {
    /// 화이트보드 객체가 추가될 때 이벤트를 방출합니다.
    var addedWhiteboardObject: AnyPublisher<WhiteboardObject, Never> { get }

    /// 화이트보드 객체가 수정될 때 이벤트를 방출합니다.
    var updatedWhiteboardObject: AnyPublisher<WhiteboardObject, Never> { get }

    /// 화이트보드 객체가 제거될 때 이벤트를 방출합니다.
    var removedWhiteboardObject: AnyPublisher<WhiteboardObject, Never> { get }

    /// 현재 존재하는 모든 화이트보드 객체들을 가져옵니다.
    /// - Returns: 화이트보드 위에 존재하는 화이트보드 객체들
    func fetchObjects() -> [WhiteboardObject]

    /// 화이트보드 객체를 추가하는 메서드
    /// - Parameter whiteboardObject: 추가할 화이트보드 객체
    func addObject(whiteboardObject: WhiteboardObject)

    /// 화이트보드 객체를 수정하는 메서드
    /// - Parameter whiteboardObject: 수정할 화이트보드 객체
    func updateObject(whiteboardObject: WhiteboardObject)

    /// 화이트보드를 제거하는 메서드
    /// - Parameter whiteboardObject: 제거할 화이트보드 객체
    func removeObject(whiteboardObject: WhiteboardObject)
}
