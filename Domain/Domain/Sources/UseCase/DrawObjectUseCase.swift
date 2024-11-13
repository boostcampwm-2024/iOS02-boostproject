//
//  DrawObjectUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/13/24.
//

import Foundation

final class DrawObjectUseCase: DrawObjectUseCaseInterface {
    private var drawingObject: DrawingObject?
    private let repository: WhiteboardObjectRepositoryInterface
    
    init(repository: WhiteboardObjectRepositoryInterface) {
        self.repository = repository
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
        
        repository.send(whiteboardObject: drawingObject)
        return drawingObject
    }
}
