//
//  WhiteboardViewController.swift
//  Presentation
//
//  Created by 박승찬 on 11/12/24.
//

import UIKit

public class WhiteboardViewController: UIViewController {
    // MARK: - UI Properties
    private let toolbar = WhiteboardToolBar(frame: .zero)

    // MARK: - Viewcontroller Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureAttribute()
    }

    // MARK: - Methods
    private func configureLayout() {
        toolbar
            .addToSuperview(view)
            .horizontalEdges(equalTo: view, inset: 22)
            .bottom(equalTo: view.safeAreaLayoutGuide.bottomAnchor, inset: 0)
            .height(equalTo: 40)
    }

    private func configureAttribute() {
        view.backgroundColor = .systemBackground
        toolbar.delegate = self
    }
}

// MARK: - WhiteboardToolBarDelegate
extension WhiteboardViewController: WhiteboardToolBarDelegate {
    func whiteboardToolBar(_ sender: WhiteboardToolBar, selectedTool: WhiteboardTool) {
        // TODO: 각 Tool에 따른 실행 동작 구현
        switch selectedTool {
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
    }
}
