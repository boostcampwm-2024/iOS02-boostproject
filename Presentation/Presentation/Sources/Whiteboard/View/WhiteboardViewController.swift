//
//  WhiteboardViewController.swift
//  Presentation
//
//  Created by 박승찬 on 11/12/24.
//

import Combine
import Domain
import PhotosUI
import UIKit

public class WhiteboardViewController: UIViewController {
    private enum WhiteboardLayoutConstant {
        static let canvaseSize: CGFloat = 2000
        static let toolbarHeight: CGFloat = 40
    }

    private let scrollView = UIScrollView()
    private let drawingView = DrawingView()
    private let canvasView = UIView()
    private let toolbar = WhiteboardToolBar(frame: .zero)
    private let viewModel: WhiteboardViewModel
    private let objectViewFactory: WhiteboardObjectViewFactoryable
    private var whiteboardObjectViews: [UUID: WhiteboardObjectView]
    private var cancellables: Set<AnyCancellable>
    private var visibleCenterPoint: CGPoint {
        let centerX = scrollView.contentOffset.x + (scrollView.bounds.width / 2)
        let centerY = scrollView.contentOffset.y + (scrollView.bounds.height / 2)
        return CGPoint(x: centerX, y: centerY)
    }

    public init(viewModel: WhiteboardViewModel, objectViewFactory: WhiteboardObjectViewFactoryable) {
        self.viewModel = viewModel
        self.objectViewFactory = objectViewFactory
        cancellables = []
        whiteboardObjectViews = [:]
        super.init(nibName: nil, bundle: nil)
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

    private func configureAttribute() {
        view.backgroundColor = .systemBackground
        drawingView.isHidden = true
        toolbar.delegate = self
        drawingView.delegate = self
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

    private func addText() {
        viewModel.action(input: .addTextObject(scrollViewOffset: scrollView.contentOffset, viewSize: view.frame.size))
    }

    // TODO: 이후에 Done 버튼이 생길경우 사용할 메소드
    private func endEditObject() {
        view.endEditing(true)
    }

    private func presentImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images

        let phpPicker = PHPickerViewController(configuration: configuration)
        phpPicker.delegate = self

        present(phpPicker, animated: true)
        viewModel.action(input: .finishUsingTool)
    }

    @objc private func handleScrollViewTapGesture(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: canvasView)
        let touchedView = canvasView.hitTest(location, with: nil)

        if let touchedView = touchedView as? WhiteboardObjectView {
            viewModel.action(input: .selectObject(objectId: touchedView.objectId))
        } else {
            viewModel.action(input: .deselectObject)
        }
    }
}

// MARK: - WhiteboardToolBarDelegate
extension WhiteboardViewController: WhiteboardToolBarDelegate {
    func whiteboardToolBar(_ sender: WhiteboardToolBar, selectedTool: WhiteboardTool) {
        viewModel.action(input: .selectTool(tool: selectedTool))
        if selectedTool == .text { addText() }
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
                let imageData = selectedImage.jpegData(compressionQuality: 1)
            else { return }

            DispatchQueue.main.async {
                self.viewModel.action(input: .addPhoto(
                    imageData: imageData,
                    position: self.visibleCenterPoint,
                    size: selectedImage.size))
            }
        }
    }
}
