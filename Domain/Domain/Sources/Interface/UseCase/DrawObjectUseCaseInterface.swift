//
//  DrawObjectUseCaseInterface.swift
//  Domain
//
//  Created by 이동현 on 11/13/24.
//

import Foundation

public protocol DrawObjectUseCaseInterface {

    /// 선을 나타내는 점들의 배열
    var points: [CGPoint] { get }

    /// 선의 굵기를 설정합니다.
    /// - Parameter width: 선의 너비
    func configureLineWidth(to width: CGFloat)

    /// 그리기를 시작합니다.
    /// - Parameter point: 시작 지점 CGPoint
    func startDrawing(at point: CGPoint)

    /// 그림 그리는 중에 새로운 점을 추가합니다.
    /// - Parameter point: 추가할 점의 CGPoint
    func addPoint(point: CGPoint)

    /// 그림 그리기를 종료합니다.
    /// - Returns: 완성된 그림 객체 (옵셔널)
    func finishDrawing() -> DrawingObject?
}
