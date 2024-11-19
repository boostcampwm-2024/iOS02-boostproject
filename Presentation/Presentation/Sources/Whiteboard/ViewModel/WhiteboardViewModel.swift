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
        case selectTool(tool: WhiteboardTool)
        case startDrawing(startAt: CGPoint)
        case addDrawingPoint(point: CGPoint)
        case finishDrawing
        case finishUsingTool
        case addTextObject(scrollViewOffset: CGPoint, viewSize: CGSize)
    }

    struct Output {
        let whiteboardToolPublisher: AnyPublisher<WhiteboardTool?, Never>
        let addedWhiteboardObjectPublisher: AnyPublisher<WhiteboardObject, Never>
        let updatedWhiteboardObjectPublisher: AnyPublisher<WhiteboardObject, Never>
        let removedWhiteboardObjectPublisher: AnyPublisher<WhiteboardObject, Never>
    }

    let output: Output
    private let drawObjectUseCase: DrawObjectUseCaseInterface
    private let textObjectUseCase: TextObjectUseCaseInterface
    private let manageWhiteboardToolUseCase: ManageWhiteboardToolUseCaseInterface
    private let manageWhiteboardObjectUseCase: ManageWhiteboardObjectUseCaseInterface

    public init(
        drawObjectUseCase: DrawObjectUseCaseInterface,
        textObjectUseCase: TextObjectUseCaseInterface,
        managemanageWhiteboardToolUseCase: ManageWhiteboardToolUseCaseInterface,
        manageWhiteboardObjectUseCase: ManageWhiteboardObjectUseCaseInterface
    ) {
        self.drawObjectUseCase = drawObjectUseCase
        self.textObjectUseCase = textObjectUseCase
        self.manageWhiteboardToolUseCase = managemanageWhiteboardToolUseCase
        self.manageWhiteboardObjectUseCase = manageWhiteboardObjectUseCase

        output = Output(
            whiteboardToolPublisher: manageWhiteboardToolUseCase
                .currentToolPublisher
                .eraseToAnyPublisher(),
            addedWhiteboardObjectPublisher: manageWhiteboardObjectUseCase
                .addedObjectPublisher
                .eraseToAnyPublisher(),
            updatedWhiteboardObjectPublisher: manageWhiteboardObjectUseCase
                .updatedObjectPublisher
                .eraseToAnyPublisher(),
            removedWhiteboardObjectPublisher: manageWhiteboardObjectUseCase
                .removedObjectPublisher
                .eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .selectTool(let tool):
            selectTool(with: tool)
        case .startDrawing(let point):
            startDrawing(at: point)
        case .addDrawingPoint(point: let point):
            addDrawingPoint(at: point)
        case .finishDrawing:
            finishDrawing()
        case .finishUsingTool:
            finishUsingTool()
        case .addTextObject(scrollViewOffset: let scrollViewOffset, viewSize: let viewSize):
            addText(scrollViewOffset: scrollViewOffset, viewSize: viewSize)
        }
    }

    private func selectTool(with tool: WhiteboardTool) {
        manageWhiteboardToolUseCase.selectTool(tool: tool)
    }

    private func finishUsingTool() {
        let currentTool = manageWhiteboardToolUseCase.currentTool()
        guard let currentTool else { return }

        switch currentTool {
        case .drawing:
            break
        case .text:
            break
        case .photo:
            break
        case .game:
            break
        case .chat:
            break
        }

        manageWhiteboardToolUseCase.finishUsingTool()
    }

    private func addWhiteboardObject(object: WhiteboardObject) {
        manageWhiteboardObjectUseCase.addObject(whiteboardObject: object)
    }

    private func startDrawing(at point: CGPoint) {
        drawObjectUseCase.startDrawing(at: point)
    }

    private func addDrawingPoint(at point: CGPoint) {
        drawObjectUseCase.addPoint(point: point)
    }

    private func finishDrawing() {
        guard let drawingObject = drawObjectUseCase.finishDrawing() else { return }
        addWhiteboardObject(object: drawingObject)
    }

    private func addText(scrollViewOffset: CGPoint, viewSize: CGSize) {
        let textObject = textObjectUseCase.addText(point: scrollViewOffset, size: viewSize)
        addWhiteboardObject(object: textObject)
    }
}
