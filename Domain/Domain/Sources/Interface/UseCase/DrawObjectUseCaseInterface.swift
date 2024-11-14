//
//  DrawObjectUseCaseInterface.swift
//  Domain
//
//  Created by 이동현 on 11/13/24.
//

import Foundation

public protocol DrawObjectUseCaseInterface {
    /// 그림을 그리기 시작한 점
    var origin: CGPoint? { get }

    /// 선을 나타내는 점들의 배열
    var points: [CGPoint] { get }

    /// 그리기를 시작하는 메서드
    /// - Parameter point: 시작 지점 CGPoint
    func startDrawing(at point: CGPoint)

    /// 그림 그리는 중에 새로운 점을 추가하는 메서드
    /// - Parameter point: 추가할 점의 CGPoint
    func addPoint(point: CGPoint)

    /// 그림 그리기를 종료하는 메서드
    /// - Returns: 완성된 그림 객체 (옵셔널)
    func finishDrawing() -> DrawingObject?
}
