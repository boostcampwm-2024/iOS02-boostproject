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
        case addPhotoObject(
            imageData: Data,
            position: CGPoint,
            size: CGSize)
        case fetchImage(imageID: UUID)
        case startDrawing(startAt: CGPoint)
        case addDrawingPoint(point: CGPoint)
        case finishDrawing
        case finishUsingTool
        case addTextObject(point: CGPoint, viewSize: CGSize)
        case editTextObject(text: String)
        case addGameObject(point: CGPoint)
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
        let imagePublisher: AnyPublisher<(id: UUID, imageData: Data), Never>
        var chatMessages: [ChatMessage]
    }

    private(set) var output: Output
    private let whiteboardUseCase: WhiteboardUseCaseInterface
    private let photoUseCase: PhotoUseCaseInterface
    private let drawObjectUseCase: DrawObjectUseCaseInterface
    private let textObjectUseCase: TextObjectUseCaseInterface
    private let chatUseCase: ChatUseCaseInterface
    private let gameObjectUseCase: GameObjectUseCaseInterface
    private let manageWhiteboardToolUseCase: ManageWhiteboardToolUseCaseInterface
    private let manageWhiteboardObjectUseCase: ManageWhiteboardObjectUseCaseInterface
    private let selectedObjectSubject: CurrentValueSubject<UUID?, Never>
    private let imageSubject: PassthroughSubject<(id: UUID, imageData: Data), Never>
    private var cancellables: Set<AnyCancellable>

    public init(
        whiteboardUseCase: WhiteboardUseCaseInterface,
        photoUseCase: PhotoUseCaseInterface,
        drawObjectUseCase: DrawObjectUseCaseInterface,
        textObjectUseCase: TextObjectUseCaseInterface,
        chatUseCase: ChatUseCaseInterface,
        gameObjectUseCase: GameObjectUseCaseInterface,
        manageWhiteboardToolUseCase: ManageWhiteboardToolUseCaseInterface,
        manageWhiteboardObjectUseCase: ManageWhiteboardObjectUseCaseInterface
    ) {
        self.whiteboardUseCase = whiteboardUseCase
        self.photoUseCase = photoUseCase
        self.drawObjectUseCase = drawObjectUseCase
        self.textObjectUseCase = textObjectUseCase
        self.chatUseCase = chatUseCase
        self.gameObjectUseCase = gameObjectUseCase
        self.manageWhiteboardToolUseCase = manageWhiteboardToolUseCase
        self.manageWhiteboardObjectUseCase = manageWhiteboardObjectUseCase
        selectedObjectSubject = CurrentValueSubject(nil)
        imageSubject = PassthroughSubject<(id: UUID, imageData: Data), Never>()
        cancellables = []

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
                .eraseToAnyPublisher(),
            imagePublisher: imageSubject.eraseToAnyPublisher(),
            chatMessages: []
        )
        receviedMessage()
    }

    func action(input: Input) {
        switch input {
        case .selectTool(let tool):
            selectTool(with: tool)
        case .addPhotoObject(let imageData, let point, let size):
            addPhoto(
                imageData: imageData,
                point: point,
                size: size)
        case .fetchImage(let imageID):
            fetchImage(imageID: imageID)
        case .startDrawing(let point):
            startDrawing(at: point)
        case .addDrawingPoint(let point):
            addDrawingPoint(at: point)
        case .finishDrawing:
            finishDrawing()
        case .finishUsingTool:
            finishUsingTool()
        case .addTextObject(let point, let viewSize):
            addText(at: point)
        case .editTextObject(let text):
            editText(text: text)
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
        case .addGameObject(let point):
            addGame(at: point)
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
            await manageWhiteboardObjectUseCase
                .addObject(whiteboardObject: object, isReceivedObject: false)
        }
    }

    private func addPhoto(
        imageData: Data,
        point: CGPoint,
        size: CGSize
    ) {
        guard
            let photoObject = photoUseCase.addPhoto(
                imageData: imageData,
                centerPosition: point,
                size: size)
        else { return }

        Task {
            await manageWhiteboardObjectUseCase
                .addObject(whiteboardObject: photoObject, isReceivedObject: false)
        }
    }

    private func fetchImage(imageID: UUID) {
        guard let imageData = photoUseCase.fetchPhoto(imageID: imageID) else { return }
        imageSubject.send((id: imageID, imageData: imageData))
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

    private func addText(at point: CGPoint) {
        let textObject = textObjectUseCase.addText(centerPoint: point)
        addWhiteboardObject(object: textObject)
    }

    private func editText(text: String) {
        guard let selectedObjectID = selectedObjectSubject.value else { return }
        Task {
            await textObjectUseCase.editText(id: selectedObjectID, text: text)
        }
    }

    private func addGame(at point: CGPoint) {
        let gameObject = gameObjectUseCase.createGame(centerPoint: point)
        addWhiteboardObject(object: gameObject)
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
            let isSuccess = await manageWhiteboardObjectUseCase
                .removeObject(whiteboardObjectID: selectedObjectID, isReceivedObject: false)
            if isSuccess { selectedObjectSubject.send(nil) }
        }
    }

    private func receviedMessage() {
        chatUseCase.chatMessagePublisher
            .sink { [weak self] chatMessage in
                self?.output.chatMessages.append(chatMessage)
            }
            .store(in: &cancellables)
    }
}
