//
//  WhiteboardToolBar.swift
//  Presentation
//
//  Created by 박승찬 on 11/12/24.
//

import Combine
import UIKit

protocol WhiteboardToolBarDelegate: AnyObject {
    func whiteboardToolBar(_ sender: WhiteboardToolBar, selectedTool: WhiteboardTool)
}

final class WhiteboardToolBar: UIStackView {
    // MARK: - UI Properties
    private let drawing = UIButton()
    private let text = UIButton()
    private let photo = UIButton()
    private let game = UIButton()
    private let chat = UIButton()

    // MARK: - Properties
    private var tools: [WhiteboardTool: UIButton] = [:]
    private var selectedTool = CurrentValueSubject<WhiteboardTool?, Never>(nil)
    private var cancellables: Set<AnyCancellable> = []
    weak var delegate: WhiteboardToolBarDelegate?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    private func initialize() {
        configureAttribute()
        configureButtons()
        bind()
    }

    // MARK: - Internal methods
    func done() {
        tools.forEach { $1.setImage($0.defaultIcon, for: .normal) }
    }

    // MARK: - Private methods
    private func configureAttribute() {
        distribution = .fillEqually
        spacing = 30
    }

    private func configureButtons() {
        let buttons = [drawing, text, photo, game, chat]
        zip(WhiteboardTool.allCases, buttons).forEach { whiteboardTool, button in
            tools[whiteboardTool] = button
            addArrangedSubview(button)
            button.tintColor = .airplainBlue
            button.addAction(
                UIAction { [weak self] _ in
                    guard let self else { return }
                    guard whiteboardTool != selectedTool.value else {
                        done()
                        return
                    }
                    self.delegate?.whiteboardToolBar(self, selectedTool: whiteboardTool)
                    self.selectedTool.send(whiteboardTool)
                },
                for: .touchUpInside )
        }
    }

    private func bind() {
        selectedTool
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tool in
                self?.done()
                guard let tool else { return }
                self?.tools[tool]?.setImage(tool.selectedIcon, for: .normal)
            }
            .store(in: &cancellables)
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
