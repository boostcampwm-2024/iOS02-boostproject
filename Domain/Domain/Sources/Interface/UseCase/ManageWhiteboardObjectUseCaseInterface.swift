//
//  ManageWhiteboardObjectUseCaseInterface.swift
//  Domain
//
//  Created by 이동현 on 11/16/24.
//

import Combine
import Foundation

public protocol ManageWhiteboardObjectUseCaseInterface {
    /// 화이트보드 객체가 추가될 때 이벤트를 방출합니다.
    var addedObjectPublisher: AnyPublisher<WhiteboardObject, Never> { get }

    /// 화이트보드 객체가 수정될 때 이벤트를 방출합니다.
    var updatedObjectPublisher: AnyPublisher<WhiteboardObject, Never> { get }

    /// 화이트보드 객체가 제거될 때 이벤트를 방출합니다.
    var removedObjectPublisher: AnyPublisher<WhiteboardObject, Never> { get }

    /// 화이트보드 객체가 선택/선택 해제될 때 이벤트를 방출합니다
    var selectedObjectIDPublisher: AnyPublisher<UUID?, Never> { get }

    /// 화이트보드 객체를 추가하는 메서드
    /// - Parameter whiteboardObject: 추가할 화이트보드 객체
    /// - Returns: 추가 성공 여부
    @discardableResult
    func addObject(whiteboardObject: WhiteboardObject) async -> Bool

    /// 화이트보드 객체를 수정하는 메서드
    /// - Parameter whiteboardObject: 수정할 화이트보드 객체
    /// - Returns: 추가 성공 여부
    @discardableResult
    func updateObject(whiteboardObject: WhiteboardObject) async -> Bool

    /// 화이트보드를 제거하는 메서드
    /// - Returns: 추가 성공 여부
    @discardableResult
    func removeObject(whiteboardObject: WhiteboardObject) async -> Bool

    /// 화이트보드 오브젝트를 선택합니다.
    /// - Parameter whiteboardObject: 선택할 오브젝트
    /// - Returns: 선택 성공 여부
    @discardableResult
    func select(whiteboardObjectID: UUID) async -> Bool

    /// 화이트보드 오브젝트를 선택 해제 합니다.
    /// - Returns:  선택 해제 성공 여부
    @discardableResult
    func deselect() async -> Bool

    /// 오브젝트의 위치를 변경합니다.
    /// - Parameters:
    ///   - whiteboardObjectID: 변경할 오브젝트의 ID
    ///   - point: 변경할 object의 원점
    /// - Returns: 위치 조정 성공 여부
    @discardableResult
    func changePosition(whiteboardObjectID: UUID, to point: CGPoint) async -> Bool

    /// 오브젝트의 크기를 변경합니다.
    /// - Parameters:
    ///   - whiteboardObjectID: 변경할 오브젝트의 ID
    ///   - point: 변경할 object의 크기
    /// - Returns: 크기 조정 성공 여부
    @discardableResult
    func changeSize(whiteboardObjectID: UUID, to scale: CGFloat) async -> Bool
}
