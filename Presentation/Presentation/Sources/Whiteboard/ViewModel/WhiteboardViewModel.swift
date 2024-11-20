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
        case addPhoto(
            imageData: Data,
            position: CGPoint,
            size: CGSize)
        case startDrawing(startAt: CGPoint)
        case addDrawingPoint(point: CGPoint)
        case finishDrawing
        case finishUsingTool
        case addTextObject(scrollViewOffset: CGPoint, viewSize: CGSize)
        case selectObject(objectId: UUID)
        case deselectObject
    }

    struct Output {
        let whiteboardToolPublisher: AnyPublisher<WhiteboardTool?, Never>
        let addedWhiteboardObjectPublisher: AnyPublisher<WhiteboardObject, Never>
        let updatedWhiteboardObjectPublisher: AnyPublisher<WhiteboardObject, Never>
        let removedWhiteboardObjectPublisher: AnyPublisher<WhiteboardObject, Never>
    }

    let output: Output
    private let whiteboardUseCase: WhiteboardUseCaseInterface
    private let addPhotoUseCase: AddPhotoUseCase
    private let drawObjectUseCase: DrawObjectUseCaseInterface
    private let textObjectUseCase: TextObjectUseCaseInterface
    private let manageWhiteboardToolUseCase: ManageWhiteboardToolUseCaseInterface
    private let manageWhiteboardObjectUseCase: ManageWhiteboardObjectUseCaseInterface

    init(
        whiteboardUseCase: WhiteboardUseCaseInterface,
        addPhotoUseCase: AddPhotoUseCase,
        drawObjectUseCase: DrawObjectUseCaseInterface,
        textObjectUseCase: TextObjectUseCaseInterface,
        managemanageWhiteboardToolUseCase: ManageWhiteboardToolUseCaseInterface,
        manageWhiteboardObjectUseCase: ManageWhiteboardObjectUseCaseInterface
    ) {
        self.whiteboardUseCase = whiteboardUseCase
        self.addPhotoUseCase = addPhotoUseCase
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
        case .addPhoto(let imageData, let point, let size):
            addPhoto(
                imageData: imageData,
                point: point,
                size: size)
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
        case .selectObject(objectId: let objectId):
            selectObject(objectId: objectId)
        case .deselectObject:
            deselectObject()
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

    private func addPhoto(
        imageData: Data,
        point: CGPoint,
        size: CGSize
    ) {
        do {
            let photoObject = try addPhotoUseCase.addPhoto(
                imageData: imageData,
                position: point,
                size: size)
            manageWhiteboardObjectUseCase.addObject(whiteboardObject: photoObject)
        } catch {
        // TODO: - 사진 추가 실패 시 오류 처리
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
        addWhiteboardObject(object: drawingObject)
    }

    private func addText(scrollViewOffset: CGPoint, viewSize: CGSize) {
        let textObject = textObjectUseCase.addText(point: scrollViewOffset, size: viewSize)
        addWhiteboardObject(object: textObject)
    }

    private func startPublishing() {
        whiteboardUseCase.startPublishingWhiteboard()
    }

    private func selectObject(objectId: UUID) {
        // TODO: - usecase의 select 함수 호출
    }

    private func deselectObject() {
        // TODO: - usecase의 deselect 함수 호출
    }
}
