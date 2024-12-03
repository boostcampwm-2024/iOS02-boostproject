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
}

final class WhiteboardToolBar: UIView {
    enum ToolBarMode {
        case normal
        case delete
    }

    private enum WhiteboardToolBarLayoutConstant {
        static let toolbarSpacing: CGFloat = 30
        static let deletionImageSize: CGFloat = 40
        static let deletionDisabledImage = "trash.circle"
        static let deletionEnabledImage = "trash.circle.fill"
    }

    private let toolStackView = UIStackView()
    private let drawing = UIButton()
    private let text = UIButton()
    private let photo = UIButton()
    private let game = UIButton()
    private let chat = UIButton()

    private let deletionImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: WhiteboardToolBarLayoutConstant.deletionDisabledImage)
        imageView.tintColor = .wordleRed
        imageView.isHidden = true
        return imageView
    }()

    private var tools: [WhiteboardTool: UIButton] = [:]
    var deleteZone: CGRect {
        return convert(deletionImage.frame, to: superview)
    }
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
            deletionImage.isHidden = true
        case .delete:
            toolStackView.isHidden = true
            deletionImage.isHidden = false
        }
    }

    func configureDeleteImage(isDeleteZoneEnable: Bool) {
        let imageName = isDeleteZoneEnable
        ? WhiteboardToolBarLayoutConstant.deletionEnabledImage
        : WhiteboardToolBarLayoutConstant.deletionDisabledImage

        deletionImage.image = UIImage(systemName: imageName)
    }

    private func configureAttribute() {
        toolStackView.distribution = .fillEqually
        toolStackView.spacing = WhiteboardToolBarLayoutConstant.toolbarSpacing
    }

    private func configureLayout() {
        toolStackView
            .addToSuperview(self)
            .edges(equalTo: self)

        deletionImage
            .addToSuperview(self)
            .center(in: self)
            .size(
                width: WhiteboardToolBarLayoutConstant.deletionImageSize,
                height: WhiteboardToolBarLayoutConstant.deletionImageSize)
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
