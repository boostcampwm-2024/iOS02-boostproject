//
//  WhiteboardViewController.swift
//  Presentation
//
//  Created by 박승찬 on 11/12/24.
//

import Combine
import Domain
import PhotosUI
import SwiftUI
import UIKit
// TODO: 추후 개선
import DataSource
import Persistence

public final class WhiteboardViewController: UIViewController {
    private enum WhiteboardLayoutConstant {
        static let canvaseSize: CGFloat = 2000
        static let toolbarHeight: CGFloat = 40
    }

    private let scrollView = UIScrollView()
    private let drawingView = DrawingView()
    private let canvasView = UIView()
    private let toolbar = WhiteboardToolBar(frame: .zero)
    private let viewModel: WhiteboardViewModel
    private var objectViewFactory: WhiteboardObjectViewFactoryable
    private var whiteboardObjectViews: [UUID: WhiteboardObjectView]
    private var selectedObjectView: WhiteboardObjectView?
    private var cancellables: Set<AnyCancellable>
    private var visibleCenterPoint: CGPoint {
        let centerX = scrollView.contentOffset.x + (scrollView.bounds.width / 2)
        let centerY = scrollView.contentOffset.y + (scrollView.bounds.height / 2)
        return CGPoint(x: centerX, y: centerY)
    }
    private let profileRepository: ProfileRepositoryInterface
    private let chatUseCase: ChatUseCaseInterface

    public init(
        viewModel: WhiteboardViewModel,
        objectViewFactory: WhiteboardObjectViewFactoryable,
        profileRepository: ProfileRepositoryInterface,
        chatUseCase: ChatUseCaseInterface
    ) {
        self.viewModel = viewModel
        self.objectViewFactory = objectViewFactory
        self.profileRepository = profileRepository
        self.chatUseCase = chatUseCase
        cancellables = []
        whiteboardObjectViews = [:]
        super.init(nibName: nil, bundle: nil)
        self.objectViewFactory.whiteboardObjectViewDelegate = self
        self.objectViewFactory.textViewDelegate = self
        self.objectViewFactory.gameObjectViewDelegate = self
        self.objectViewFactory.photoObjectViewDelegate = self
    }

    public required init?(coder: NSCoder) {
        fatalError("WhiteboardViewController 초기화 오류")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureAttribute()
        configureScrollView()
        bind()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    private func configureAttribute() {
        let editDoneButton = UIBarButtonItem(
            title: "완료",
            style: .done,
            target: self,
            action: #selector(endEditObject))
        navigationItem.rightBarButtonItem = editDoneButton
        navigationController?.navigationBar.backItem?.title = ""
        navigationController?.isNavigationBarHidden = false
        view.backgroundColor = .systemBackground

        drawingView.isHidden = true
        toolbar.delegate = self
        drawingView.delegate = self
        viewModel.action(input: .finishUsingTool)
    }

    private func configureLayout() {
        scrollView
            .addToSuperview(view)
            .top(equalTo: view.safeAreaLayoutGuide.topAnchor, inset: .zero)
            .bottom(equalTo: view.safeAreaLayoutGuide.bottomAnchor, inset: .zero)
            .horizontalEdges(equalTo: view)

        canvasView
            .addToSuperview(scrollView)
            .top(equalTo: scrollView.contentLayoutGuide.topAnchor, inset: .zero)
            .bottom(equalTo: scrollView.contentLayoutGuide.bottomAnchor, inset: .zero)
            .leading(equalTo: scrollView.contentLayoutGuide.leadingAnchor, inset: .zero)
            .trailing(equalTo: scrollView.contentLayoutGuide.trailingAnchor, inset: .zero)
            .size(
                width: WhiteboardLayoutConstant.canvaseSize,
                height: WhiteboardLayoutConstant.canvaseSize)

        drawingView
            .addToSuperview(scrollView)
            .edges(equalTo: canvasView)

        toolbar
            .addToSuperview(view)
            .horizontalEdges(equalTo: view, inset: horizontalMargin)
            .bottom(equalTo: view.safeAreaLayoutGuide.bottomAnchor, inset: .zero)
            .height(equalTo: WhiteboardLayoutConstant.toolbarHeight)
    }

    private func bind() {
        viewModel.output.whiteboardToolPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tool in
                self?.toolbar.select(tool: tool)
                self?.configureDrawingView(isDrawing: tool == .drawing)
                self?.navigationItem.rightBarButtonItem?.isHidden = tool == nil

                guard let tool else { return }

                switch tool {
                case .photo:
                    self?.presentImagePicker()
                default:
                    break
                }
            }
            .store(in: &cancellables)

        viewModel.output.addedWhiteboardObjectPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] object in
                guard let objectView = self?.objectViewFactory.create(with: object) else { return }
                self?.addObjectView(objectView: objectView)
                self?.whiteboardObjectViews[object.id] = objectView
                objectView.becomeFirstResponder()
            }
            .store(in: &cancellables)

        viewModel.output.updatedWhiteboardObjectPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] object in
                guard let objectView = self?.whiteboardObjectViews[object.id] else { return }
                objectView.update(with: object)
            }
            .store(in: &cancellables)

        viewModel.output.removedWhiteboardObjectPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] object in
                guard let objectView = self?.whiteboardObjectViews[object.id] else { return }
                self?.whiteboardObjectViews.removeValue(forKey: object.id)
                objectView.removeFromSuperview()
            }
            .store(in: &cancellables)

        viewModel.output.objectViewSelectedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] objectID in
                if
                    let objectID,
                    let objectView = self?.whiteboardObjectViews[objectID]
                {
                    self?.selectedObjectView = objectView
                    self?.selectedObjectView?.configureEditable(isEditable: true)
                    self?.navigationItem.rightBarButtonItem?.isHidden = false
                    self?.toolbar.configure(with: .delete)
                } else {
                    self?.selectedObjectView?.configureEditable(isEditable: false)
                    self?.selectedObjectView = nil
                    self?.navigationItem.rightBarButtonItem?.isHidden = true
                    self?.toolbar.configure(with: .normal)
                }
            }
            .store(in: &cancellables)

        viewModel.output.imagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (id: UUID, imageData: Data) in
                guard
                    let objectView = self?.whiteboardObjectViews[id],
                    let photoObjectView = objectView as? PhotoObjectView
                else { return }

                photoObjectView.configureImage(imageData: imageData)
            }
            .store(in: &cancellables)
    }

    private func configureDrawingView(isDrawing: Bool) {
        drawingView.isHidden = !isDrawing
        scrollView.panGestureRecognizer.minimumNumberOfTouches = isDrawing ? 2 : 1
        if isDrawing { drawingView.reset() }
    }

    private func configureScrollView() {
        let scrollViewTapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleScrollViewTapGesture))
        scrollViewTapGestureRecognizer.numberOfTapsRequired = 1
        scrollViewTapGestureRecognizer.isEnabled = true
        scrollViewTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(scrollViewTapGestureRecognizer)
    }

    private func addObjectView(objectView: WhiteboardObjectView) {
        canvasView.addSubview(objectView)
    }

    @objc private func endEditObject() {
        view.endEditing(true)
        viewModel.action(input: .finishUsingTool)
        viewModel.action(input: .deselectObject)
    }

    private func presentImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images

        let phpPicker = PHPickerViewController(configuration: configuration)
        phpPicker.delegate = self

        present(phpPicker, animated: true)
        viewModel.action(input: .finishUsingTool)
    }

    @objc private func handleScrollViewTapGesture(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: canvasView)
        let touchedView = canvasView.hitTest(location, with: nil)

        if let touchedView = touchedView as? WhiteboardObjectView {
            viewModel.action(input: .selectObject(objectID: touchedView.objectID))
        } else {
            viewModel.action(input: .deselectObject)
        }
    }

    private func presentChatViewController() {
        let chatViewModel = ChatViewModel(
            chatUseCase: chatUseCase,
            profileRepository: profileRepository,
            chatMessages: viewModel.output.chatMessages)
        let chatViewController = ChatViewController(viewModel: chatViewModel)
        self.present(chatViewController, animated: true)
    }
}

// MARK: - WhiteboardToolBarDelegate
extension WhiteboardViewController: WhiteboardToolBarDelegate {
    func whiteboardToolBar(_ sender: WhiteboardToolBar, selectedTool: WhiteboardTool) {
        guard selectedTool != .chat else {
            self.presentChatViewController()
            return
        }
        viewModel.action(input: .selectTool(tool: selectedTool))

        if selectedTool == .text {
            viewModel.action(input: .addTextObject(point: visibleCenterPoint, viewSize: view.frame.size))
            viewModel.action(input: .finishUsingTool)
        } else if selectedTool == .game {
            viewModel.action(input: .addGameObject(point: visibleCenterPoint))
            viewModel.action(input: .finishUsingTool)
        }
    }

    func whiteboardToolBarDidTapDeleteButton(_ sender: WhiteboardToolBar) {
        viewModel.action(input: .deleteObject)
    }
}

// MARK: - DrawingViewDelegate
extension WhiteboardViewController: DrawingViewDelegate {
    func drawingViewDidStartDrawing(_ sender: DrawingView, at point: CGPoint) {
        viewModel.action(input: .startDrawing(startAt: point))
    }

    func drawingView(_ sender: DrawingView, at point: CGPoint) {
        viewModel.action(input: .addDrawingPoint(point: point))
    }

    func drawingViewDidEndDrawing(_ sender: DrawingView) {
        viewModel.action(input: .finishDrawing)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension WhiteboardViewController: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        guard
            let itemProvider = results.first?.itemProvider,
            itemProvider.canLoadObject(ofClass: UIImage.self)
        else { return }

        itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
            guard
                let selectedImage = image as? UIImage,
                let imageData = selectedImage.jpegData(compressionQuality: 0.1)
            else { return }

            DispatchQueue.main.async {
                self.viewModel.action(input: .addPhotoObject(
                    imageData: imageData,
                    position: self.visibleCenterPoint,
                    size: selectedImage.size))
            }
        }
    }
}

extension WhiteboardViewController: WhiteboardObjectViewDelegate {
    public func whiteboardObjectViewDidEndScaling(
        _ sender: WhiteboardObjectView,
        scale: CGFloat,
        angle: CGFloat
    ) {
        viewModel.action(input: .changeObjectScaleAndAngle(scale: scale, angle: angle))
    }

    public func whiteboardObjectViewDidEndMoving(_ sender: WhiteboardObjectView, newCenter: CGPoint) {
        viewModel.action(input: .changeObjectPosition(point: newCenter))
    }
}

extension WhiteboardViewController: UITextViewDelegate {
    public func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard text != "\n" else {
            textView.resignFirstResponder()
            viewModel.action(input: .editTextObject(text: textView.text ?? ""))
            return false
        }

        let maxLength = 20
        guard let originText = textView.text else { return true }
        let newlength = originText.count + text.count - range.length
        return newlength < maxLength
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.action(input: .editTextObject(text: textView.text ?? ""))
    }
}

extension WhiteboardViewController: GameObjectViewDelegate {
    public func gameObjectViewDidDoubleTap(_ sender: GameObjectView, gameObject: GameObject) {
        viewModel.action(input: .deselectObject)
        let gameRepository = GameRepository(persistenceService: PersistenceService())
        let wordelViewModel = WordleViewModel(gameRepository: gameRepository, gameObject: gameObject)
        let wordleView = WordleView(viewModel: wordelViewModel)
        let hostingController = UIHostingController(rootView: NavigationStack { wordleView })
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }
}

extension WhiteboardViewController: PhotoObjectViewDelegate {
    public func photoObjectViewWillConfigurePhoto(_ sender: PhotoObjectView) {
        viewModel.action(input: .fetchImage(imageID: sender.objectID))
    }
}
