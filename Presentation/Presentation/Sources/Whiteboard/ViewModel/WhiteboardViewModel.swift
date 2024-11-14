//
//  WhiteboardViewModel.swift
//  Presentation
//
//  Created by 이동현 on 11/13/24.
//
import Combine
import Domain
import Foundation

final class WhiteboardViewModel: ViewModel {
    enum Input {
        // TODO: - tool을 바꾸는(선택하는) case 추가
        case startDrawing(startAt: CGPoint)
        case addDrawingPoint(point: CGPoint)
        case finishDrawing
    }

    struct Output {
        let whiteboardObjectsPublisher: AnyPublisher<[WhiteboardObject], Never>
    }

    let output: Output
    private let drawObjectUseCase: DrawObjectUseCaseInterface
    private var whiteboardObjects = CurrentValueSubject<[WhiteboardObject], Never>([])

    init(drawObjectUseCase: DrawObjectUseCaseInterface) {
        self.drawObjectUseCase = drawObjectUseCase

        output = Output(whiteboardObjectsPublisher: whiteboardObjects.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .startDrawing(let point):
            startDrawing(at: point)
        case .addDrawingPoint(point: let point):
            addDrawingPoint(at: point)
        case .finishDrawing:
            finishDrawing()
        }
    }

    private func startDrawing(at point: CGPoint) {
        drawObjectUseCase.startDrawing(at: point)
    }

    private func addDrawingPoint(at point: CGPoint) {
        drawObjectUseCase.addPoint(point: point)
    }

    private func finishDrawing() {
        guard let drawingObject = drawObjectUseCase.finishDrawing() else { return }
        var newObjects = whiteboardObjects.value
        newObjects.append(drawingObject)
        whiteboardObjects.send(newObjects)
    }
}
