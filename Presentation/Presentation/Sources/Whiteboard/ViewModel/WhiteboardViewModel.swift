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
        case startUsingTool(tool: WhiteboardTool)
        case startDrawing(startAt: CGPoint)
        case addDrawingPoint(point: CGPoint)
        case finishUsingTool
    }

    struct Output {
        let whiteboardToolPublisher: AnyPublisher<WhiteboardTool?, Never>
        let addedWhiteboardObjectPublisher: AnyPublisher<WhiteboardObject, Never>
        let updatedWhiteboardObjectPublisher: AnyPublisher<WhiteboardObject, Never>
        let removedWhiteboardObjectPublisher: AnyPublisher<WhiteboardObject, Never>
    }

    let output: Output
    private let drawObjectUseCase: DrawObjectUseCaseInterface
    private var whiteboardObjects: [WhiteboardObject]
    private let currentTool: CurrentValueSubject<WhiteboardTool?, Never>
    let addedWhiteboardObjectSubject: PassthroughSubject<WhiteboardObject, Never>
    let updatedWhiteboardObjectSubject: PassthroughSubject<WhiteboardObject, Never>
    let removedWhiteboardObjectSubject: PassthroughSubject<WhiteboardObject, Never>

    init(drawObjectUseCase: DrawObjectUseCaseInterface) {
        self.drawObjectUseCase = drawObjectUseCase
        whiteboardObjects = []
        currentTool = CurrentValueSubject<WhiteboardTool?, Never>(nil)
        addedWhiteboardObjectSubject = PassthroughSubject<WhiteboardObject, Never>()
        updatedWhiteboardObjectSubject = PassthroughSubject<WhiteboardObject, Never>()
        removedWhiteboardObjectSubject = PassthroughSubject<WhiteboardObject, Never>()

        output = Output(
            whiteboardToolPublisher: currentTool.eraseToAnyPublisher(),
            addedWhiteboardObjectPublisher: addedWhiteboardObjectSubject.eraseToAnyPublisher(),
            updatedWhiteboardObjectPublisher: updatedWhiteboardObjectSubject.eraseToAnyPublisher(),
            removedWhiteboardObjectPublisher: removedWhiteboardObjectSubject.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .startUsingTool(let tool):
            startUsingTool(with: tool)
        case .startDrawing(let point):
            startDrawing(at: point)
        case .addDrawingPoint(point: let point):
            addDrawingPoint(at: point)
        case .finishUsingTool:
            finishUsingTool()
        }
    }

    private func startUsingTool(with tool: WhiteboardTool) {
        currentTool.send(tool)
    }

    private func finishUsingTool() {
        guard let currentTool = currentTool.value else { return }

        switch currentTool {
        case .drawing:
            finishDrawing()
        case .text:
            break
        case .photo:
            break
        case .game:
            break
        case .chat:
            break
        }

        self.currentTool.send(nil)
    }

    private func addWhiteboardObject(object: WhiteboardObject) {
        guard !whiteboardObjects.contains(object) else { return }
        whiteboardObjects.append(object)
    }

    private func startDrawing(at point: CGPoint) {
        drawObjectUseCase.startDrawing(at: point)
    }

    private func addDrawingPoint(at point: CGPoint) {
        drawObjectUseCase.addPoint(point: point)
    }

    private func finishDrawing() {
        guard let drawingObject = drawObjectUseCase.finishDrawing() else { return }
        addedWhiteboardObjectSubject.send(drawingObject)
        addWhiteboardObject(object: drawingObject)
    }
}
