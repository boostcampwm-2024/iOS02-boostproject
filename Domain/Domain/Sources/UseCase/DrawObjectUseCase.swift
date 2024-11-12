//
//  DrawObjectUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/13/24.
//

import Foundation

final class DrawObjectUseCase: DrawObjectUseCaseInterface {
    private var drawingObject: DrawingObject?
    //TODO: - Repository 프로퍼티 추가
    
    init() {
        //TODO: - Repository 주입
    }
    
    func startDrawing(at point: CGPoint) {
        drawingObject = DrawingObject(
            id: UUID(),
            position: point,
            size: CGSize(),
            points: [point])
    }
    
    func addPoint(point: CGPoint) {
        drawingObject?.addPoint(point: point)
    }
    
    func finishDrawing() -> DrawingObject? {
        defer { drawingObject = nil }
        guard let drawingObject else { return nil }
        
        //TODO: - Repository 정의 후 적절한 처리
        return drawingObject
    }
}
