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

    /// 화이트보드 오브젝트를 추가합니다.
    /// - Parameters:
    ///   - whiteboardObject: 추가할 오브젝트
    ///   - isReceivedObject: 기기 외부로부터 수신 받았는지 여부
    /// - Returns: 추가 성공 여부
    @discardableResult
    func addObject(whiteboardObject: WhiteboardObject, isReceivedObject: Bool) async -> Bool

    /// 화이트보드 오브젝트를 수정합니다.
    /// - Parameters:
    ///   - whiteboardObject: 수정할 오브젝트
    ///   - isReceivedObject: 기기 외부로부터 수신 받았는지 여부
    /// - Returns: 수정 성공 여부
    @discardableResult
    func updateObject(whiteboardObject: WhiteboardObject, isReceivedObject: Bool) async -> Bool

    /// 화이트보드 오브젝트를 제거합니다.
    /// - Parameters:
    ///   - whiteboardObjectID: 제거할 오브젝트의 ID
    ///   - isReceivedObject: 기기 외부로부터 수신 받았는지 여부
    /// - Returns: 삭제 성공 여부
    @discardableResult
    func removeObject(whiteboardObjectID: UUID, isReceivedObject: Bool) async -> Bool

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

    /// 화이트보드 오브젝트의 크기와 회전 각도를 변경합니다.
    /// - Parameters:
    ///   - whiteboardObjectID: 변경할 오브젝트의 ID
    ///   - scale: 변경할 크기 (옵셔널)
    ///   - angle: 변경할 각도 (옵셔널)
    /// - Returns: 변경 성공 여부
    @discardableResult
    func changeSizeAndAngle(
        whiteboardObjectID: UUID,
        scale: CGFloat,
        angle: CGFloat) async -> Bool
}
