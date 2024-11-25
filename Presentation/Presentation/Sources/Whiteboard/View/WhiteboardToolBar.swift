//
//  WhiteboardToolBar.swift
//  Presentation
//
//  Created by 박승찬 on 11/12/24.
//

import Domain
import UIKit

protocol WhiteboardToolBarDelegate: AnyObject {
    func whiteboardToolBar(_ sender: WhiteboardToolBar, selectedTool: WhiteboardTool)
    func whiteboardToolBarDidTapDeleteButton(_ sender: WhiteboardToolBar)
}

final class WhiteboardToolBar: UIView {
    enum ToolBarMode {
        case normal
        case delete
    }

    private enum WhiteboardToolBarLayoutConstant {
        static let toolbarSpacing: CGFloat = 30
        static let deleteButtonWidth: CGFloat = 50
    }

    private let toolStackView = UIStackView()
    private let drawing = UIButton()
    private let text = UIButton()
    private let photo = UIButton()
    private let game = UIButton()
    private let chat = UIButton()
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(
            UIImage(systemName: "trash.circle"),
            for: .normal)
        button.tintColor = .wordleRed
        button.isHidden = true
        return button
    }()
    private var tools: [WhiteboardTool: UIButton] = [:]
    weak var delegate: WhiteboardToolBarDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    private func initialize() {
        configureAttribute()
        configureLayout()
        configureButtons()
    }

    func select(tool: WhiteboardTool?) {
        tools.forEach { $1.setImage($0.defaultIcon, for: .normal) }
        if let tool {
            tools[tool]?.setImage(tool.selectedIcon, for: .normal)
        }
    }

    func configure(with mode: ToolBarMode) {
        switch mode {
        case .normal:
            toolStackView.isHidden = false
            deleteButton.isHidden = true
        case .delete:
            toolStackView.isHidden = true
            deleteButton.isHidden = false
        }
    }

    private func configureAttribute() {
        toolStackView.distribution = .fillEqually
        toolStackView.spacing = WhiteboardToolBarLayoutConstant.toolbarSpacing
    }

    private func configureLayout() {
        toolStackView
            .addToSuperview(self)
            .edges(equalTo: self)

        deleteButton
            .addToSuperview(self)
            .size(
                width: WhiteboardToolBarLayoutConstant.deleteButtonWidth,
                height: 40,
                priority: .defaultLow)
            .verticalEdges(equalTo: self)
            .centerX(equalTo: self.centerXAnchor)
    }

    private func configureButtons() {
        let buttons = [drawing, text, photo, game, chat]
        zip(WhiteboardTool.allCases, buttons).forEach { whiteboardTool, button in
            tools[whiteboardTool] = button
            toolStackView.addArrangedSubview(button)
            button.setImage(whiteboardTool.defaultIcon, for: .normal)
            button.tintColor = .airplainBlue
            button.addAction(
                UIAction { [weak self] _ in
                    guard let self else { return }
                    self.delegate?.whiteboardToolBar(self, selectedTool: whiteboardTool)
                },
                for: .touchUpInside )
        }

        deleteButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.whiteboardToolBarDidTapDeleteButton(self)
            },
            for: .touchUpInside)
    }
}

// MARK: - WhiteboardToolExtension
extension WhiteboardTool {
    fileprivate var defaultIcon: UIImage? {
        switch self {
        case .drawing:
            UIImage(systemName: "pencil.tip.crop.circle")
        case .text:
            UIImage(systemName: "character.textbox")
        case .photo:
            UIImage(systemName: "photo.on.rectangle")
        case .game:
            UIImage(systemName: "gamecontroller")
        case .chat:
            UIImage(systemName: "ellipsis.message")
        }
    }

    fileprivate var selectedIcon: UIImage? {
        switch self {
        case .drawing:
            UIImage(systemName: "pencil.tip.crop.circle.fill")
        case .text:
            UIImage(systemName: "character.textbox")
        case .photo:
            UIImage(systemName: "photo.fill.on.rectangle.fill")
        case .game:
            UIImage(systemName: "gamecontroller.fill")
        case .chat:
            UIImage(systemName: "ellipsis.message.fill")
        }
    }
}
