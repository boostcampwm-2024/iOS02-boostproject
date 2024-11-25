//
//  WhiteboardViewModel.swift
//  Presentation
//
//  Created by 이동현 on 11/13/24.
//
import Combine
import Domain
import Foundation

public final class WhiteboardViewModel: ViewModel {
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
        case addTextObject(point: CGPoint, viewSize: CGSize)
        case selectObject(objectID: UUID)
        case deselectObject
        case changeObjectScale(objectID: UUID, scale: CGFloat)
        case changeObjectPosition(objectID: UUID, point: CGPoint)
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

    public init(
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
                .currentToolPublisher,
            addedWhiteboardObjectPublisher: manageWhiteboardObjectUseCase
                .addedObjectPublisher,
            updatedWhiteboardObjectPublisher: manageWhiteboardObjectUseCase
                .updatedObjectPublisher,
            removedWhiteboardObjectPublisher: manageWhiteboardObjectUseCase
                .removedObjectPublisher
        )
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
        case .addDrawingPoint(let point):
            addDrawingPoint(at: point)
        case .finishDrawing:
            finishDrawing()
        case .finishUsingTool:
            finishUsingTool()
        case .addTextObject(let point, let viewSize):
            addText(at: point, viewSize: viewSize)
        case .selectObject(let objectID):
            selectObject(objectID: objectID)
        case .deselectObject:
            deselectObject()
        case .changeObjectScale(let objectID, let scale):
            changeObjectScale(objectID: objectID, to: scale)
        case .changeObjectPosition(let objectID, let position):
            changeObjectPosition(objectID: objectID, to: position)
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
        Task {
            await manageWhiteboardObjectUseCase.addObject(whiteboardObject: object)
        }
    }

    private func addPhoto(
        imageData: Data,
        point: CGPoint,
        size: CGSize
    ) {
        do {
            let photoObject = try addPhotoUseCase.addPhoto(
                imageData: imageData,
                centerPosition: point,
                size: size)
            Task {
                await manageWhiteboardObjectUseCase.addObject(whiteboardObject: photoObject)
            }
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

    private func addText(at point: CGPoint, viewSize: CGSize) {
        let textObject = textObjectUseCase.addText(centerPoint: point, size: viewSize)
        addWhiteboardObject(object: textObject)
    }

    private func startPublishing() {
        whiteboardUseCase.startPublishingWhiteboard()
    }

    private func selectObject(objectID: UUID) {
        Task {
            await manageWhiteboardObjectUseCase.select(whiteboardObjectID: objectID)
        }
    }

    private func deselectObject() {
        Task {
            await manageWhiteboardObjectUseCase.deselect()
        }
    }

    private func changeObjectScale(objectID: UUID, to scale: CGFloat) {
        Task {
            await manageWhiteboardObjectUseCase.changeSize(whiteboardObjectID: objectID, to: scale)
        }
    }

    private func changeObjectPosition(objectID: UUID, to point: CGPoint) {
        Task {
            await manageWhiteboardObjectUseCase.changePosition(whiteboardObjectID: objectID, to: point)
        }
    }
}
