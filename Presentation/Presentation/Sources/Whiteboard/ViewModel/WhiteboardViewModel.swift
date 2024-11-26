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
        case changeObjectScaleAndAngle(scale: CGFloat, angle: CGFloat)
        case changeObjectPosition(point: CGPoint)
        case deleteObject
    }

    struct Output {
        let whiteboardToolPublisher: AnyPublisher<WhiteboardTool?, Never>
        let addedWhiteboardObjectPublisher: AnyPublisher<WhiteboardObject, Never>
        let updatedWhiteboardObjectPublisher: AnyPublisher<WhiteboardObject, Never>
        let removedWhiteboardObjectPublisher: AnyPublisher<WhiteboardObject, Never>
        let objectViewSelectedPublisher: AnyPublisher<UUID?, Never>
    }

    let output: Output
    private let whiteboardUseCase: WhiteboardUseCaseInterface
    private let addPhotoUseCase: AddPhotoUseCase
    private let drawObjectUseCase: DrawObjectUseCaseInterface
    private let textObjectUseCase: TextObjectUseCaseInterface
    private let manageWhiteboardToolUseCase: ManageWhiteboardToolUseCaseInterface
    private let manageWhiteboardObjectUseCase: ManageWhiteboardObjectUseCaseInterface
    private let selectedObjectSubject: CurrentValueSubject<UUID?, Never>

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
        selectedObjectSubject = CurrentValueSubject(nil)

        output = Output(
            whiteboardToolPublisher: manageWhiteboardToolUseCase
                .currentToolPublisher,
            addedWhiteboardObjectPublisher: manageWhiteboardObjectUseCase
                .addedObjectPublisher,
            updatedWhiteboardObjectPublisher: manageWhiteboardObjectUseCase
                .updatedObjectPublisher,
            removedWhiteboardObjectPublisher: manageWhiteboardObjectUseCase
                .removedObjectPublisher,
            objectViewSelectedPublisher: selectedObjectSubject
                .eraseToAnyPublisher()
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
        case .changeObjectScaleAndAngle(let scale, let angle):
            changeObjectScale(scale: scale, angle: angle)
        case .changeObjectPosition(let position):
            changeObjectPosition(to: position)
        case .deleteObject:
            deleteObject()
        }
    }

    private func selectTool(with tool: WhiteboardTool) {
        manageWhiteboardToolUseCase.selectTool(tool: tool)
        deselectObject()
    }

    private func finishUsingTool() {
        let currentTool = manageWhiteboardToolUseCase.currentTool()
        guard let currentTool else { return }

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
        guard
            let photoObject = addPhotoUseCase.addPhoto(
                imageData: imageData,
                centerPosition: point,
                size: size)
        else { return }

        Task {
            await manageWhiteboardObjectUseCase.addObject(whiteboardObject: photoObject)
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
        guard manageWhiteboardToolUseCase.currentTool() == nil else { return }
        Task {
            let isSuccess = await manageWhiteboardObjectUseCase.select(whiteboardObjectID: objectID)
            if isSuccess {
                selectedObjectSubject.send(nil)
                selectedObjectSubject.send(objectID)
            }
        }
    }

    private func deselectObject() {
        Task {
            let isSuccess = await manageWhiteboardObjectUseCase.deselect()
            if isSuccess { selectedObjectSubject.send(nil) }
        }
    }

    private func changeObjectScale(scale: CGFloat, angle: CGFloat) {
        guard let selectedObjectID = selectedObjectSubject.value else { return }
        Task {
            await manageWhiteboardObjectUseCase.changeSizeAndAngle(
                whiteboardObjectID: selectedObjectID,
                scale: scale,
                angle: angle)
        }
    }

    private func changeObjectPosition(to point: CGPoint) {
        guard let selectedObjectID = selectedObjectSubject.value else { return }
        Task {
            await manageWhiteboardObjectUseCase.changePosition(whiteboardObjectID: selectedObjectID, to: point)
        }
    }

    private func deleteObject() {
        guard let selectedObjectID = selectedObjectSubject.value else { return }
        Task {
            let isSuccess = await manageWhiteboardObjectUseCase.removeObject(whiteboardObjectID: selectedObjectID)
            if isSuccess { selectedObjectSubject.send(nil) }
        }
    }
}
