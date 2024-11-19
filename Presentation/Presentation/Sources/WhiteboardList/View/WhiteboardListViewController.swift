//
//  WhiteboardListViewController.swift
//  Presentation
//
//  Created by 최다경 on 11/12/24.
//

import Combine
import Domain
import UIKit

public final class WhiteboardListViewController: UIViewController {
    private enum WhiteboardListLayoutConstant {
        static let buttonSize: CGFloat = 26
        static let upperComponentTopMargin: CGFloat = 70
        static let mainTitleLabelWidth: CGFloat = 199
        static let mainTitleLabelHeight: CGFloat = 43
    }

    private let mainTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "AirplaIN"
        label.textColor = .airplainBlack
        label.font = AirplainFont.Heading1
        return label
    }()

    private let createWhiteboardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = .airplainBlue
        return button
    }()

    private let configureProfileButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
        button.tintColor = .airplainBlue
        return button
    }()

    private let viewModel: WhiteboardListViewModel
    private var cancellables = Set<AnyCancellable>()

    public init(viewModel: WhiteboardListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
        bind()
    }

    private func configureAttribute() {
        view.backgroundColor = .systemBackground

        let createWhiteboardAction = UIAction { [weak self] _ in
            self?.viewModel.action(input: .createWhiteboard)
        }
        createWhiteboardButton.addAction(createWhiteboardAction, for: .touchUpInside)
    }

    private func configureLayout() {
        mainTitleLabel
            .addToSuperview(view)
            .size(width: WhiteboardListLayoutConstant.mainTitleLabelWidth,
                  height: WhiteboardListLayoutConstant.mainTitleLabelHeight)
            .top(equalTo: view.topAnchor,
                 inset: WhiteboardListLayoutConstant.upperComponentTopMargin)
            .leading(equalTo: view.leadingAnchor, inset: 22)

        configureProfileButton
            .addToSuperview(view)
            .size(width: WhiteboardListLayoutConstant.buttonSize,
                  height: WhiteboardListLayoutConstant.buttonSize)
            .top(equalTo: view.topAnchor,
                 inset: WhiteboardListLayoutConstant.upperComponentTopMargin)
            .trailing(equalTo: view.trailingAnchor, inset: 22)

        createWhiteboardButton
            .addToSuperview(view)
            .size(width: WhiteboardListLayoutConstant.buttonSize,
                  height: WhiteboardListLayoutConstant.buttonSize)
            .top(equalTo: view.topAnchor,
                 inset: WhiteboardListLayoutConstant.upperComponentTopMargin)
            .trailing(equalTo: configureProfileButton.leadingAnchor, inset: 29)
    }

    private func bind() {
        viewModel.output.whiteboardPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // TODO: 화이트보드 추가
            }
            .store(in: &cancellables)
    }
}
