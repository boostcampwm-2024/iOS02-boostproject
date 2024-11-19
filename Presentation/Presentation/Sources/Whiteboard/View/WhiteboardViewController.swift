//
//  WhiteboardViewController.swift
//  Presentation
//
//  Created by 박승찬 on 11/12/24.
//

import Combine
import Domain
import UIKit

public class WhiteboardViewController: UIViewController {
    private enum WhiteboardLayoutConstant {
        static let canvaseSize: CGFloat = 1500
        static let toolbarHeight: CGFloat = 40
    }

    // TODO: - indicator 표시 여부 논의 필요
    private let scrollView = UIScrollView()
    private let drawingView = DrawingView()
    private let canvasView = UIView()
    private let toolbar = WhiteboardToolBar(frame: .zero)
    private let viewModel: WhiteboardViewModel
    private let objectViewFactory: WhiteboardObjectViewFactoryable
    private var cancellables: Set<AnyCancellable>

    init(viewModel: WhiteboardViewModel, objectViewFactory: WhiteboardObjectViewFactoryable) {
        self.viewModel = viewModel
        self.objectViewFactory = objectViewFactory
        cancellables = []
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("WhiteboardViewController 초기화 오류")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
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
            }
            .store(in: &cancellables)

        viewModel.output.addedWhiteboardObjectPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] object in
                guard let objectView = self?.objectViewFactory.create(with: object) else { return }
                self?.addObjectView(objectView: objectView)
            }
            .store(in: &cancellables)

        viewModel.output.updatedWhiteboardObjectPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // TODO: - 오브젝트 수정 시 동작 구현
            }
            .store(in: &cancellables)

        viewModel.output.removedWhiteboardObjectPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // TODO: - 오브젝트 삭제 시 동작 구현
            }
            .store(in: &cancellables)
    }

    private func configureDrawingView(isDrawing: Bool) {
        drawingView.isHidden = !isDrawing
        scrollView.panGestureRecognizer.minimumNumberOfTouches = isDrawing ? 2 : 1
        if isDrawing { drawingView.reset() }
    }

    private func addObjectView(objectView: WhiteboardObjectView) {
        canvasView.addSubview(objectView)
    }

    private func addText() {
        viewModel.action(input: .addTextObject(scrollViewOffset: scrollView.contentOffset, viewSize: view.frame.size))
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
