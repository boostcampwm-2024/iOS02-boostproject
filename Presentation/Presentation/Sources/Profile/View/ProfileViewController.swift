//
//  ProfileViewController.swift
//  Presentation
//
//  Created by 최정인 on 11/13/24.
//

import Combine
import UIKit

final class ProfileViewController: UIViewController {
    private enum ProfileLayoutConstant {
        static let profileIconWidthDivide: CGFloat = 3
        static let profileIconSettingButtonSize: CGFloat = 30
        static let dividerHeight: CGFloat = 1
        static let profileIconTopMargin: CGFloat = 30
        static let profileIconSettingButtonBottomMargin: CGFloat = 10
        static let nicknameLabelTopMargin: CGFloat = 40
        static let nicknameTextFieldTopMargin: CGFloat = 15
        static let dividerTopMargin: CGFloat = 8
        static let nicknameCountStackViewTopMargin: CGFloat = 10
    }

    private var closeButton = UIBarButtonItem()
    private var completeButton = UIBarButtonItem()
    private lazy var profileIcon: ProfileIconView = {
        let profileIcon = ProfileIconView(
            profileIcon: viewModel.output.profile.value.profileIcon,
            profileIconSize: view.bounds.width / ProfileLayoutConstant.profileIconWidthDivide)
        return profileIcon
    }()

    private let profileIconSettingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
        button.tintColor = .gray400
        button.backgroundColor = .white
        button.layer.cornerRadius = ProfileLayoutConstant.profileIconSettingButtonSize / 2
        button.contentMode = .scaleAspectFit
        button.clipsToBounds = true
        return button
    }()

    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.textColor = .gray500
        label.font = AirplainFont.Subtitle1
        return label
    }()

    private lazy var nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "닉네임을 입력해주세요."
        textField.textColor = .airplainBlack
        textField.clearButtonMode = .whileEditing
        textField.font = AirplainFont.Body2
        textField.text = viewModel.output.profile.value.nickname
        return textField
    }()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .gray500
        view.height(equalTo: ProfileLayoutConstant.dividerHeight)
        return view
    }()

    private var nicknameCountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()

    private lazy var nicknameCountLabel: UILabel = {
        let label = UILabel()
        label.text = "\(viewModel.output.profile.value.nickname.count)/\(nicknameMaxCount)"
        label.textColor = .gray500
        label.font = AirplainFont.Body4
        return label
    }()

    private let nicknameMaxCount = 15
    private let viewModel: ProfileViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
        bind()
    }

    private func configureAttribute() {
        view.backgroundColor = .systemBackground

        title = "프로필 설정"
        navigationItem.largeTitleDisplayMode = .inline

        closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(dismissView))
        closeButton.tintColor = .airplainBlack
        navigationItem.leftBarButtonItem = closeButton

        completeButton = UIBarButtonItem(
            title: "완료",
            style: .plain,
            target: self,
            action: #selector(saveProfile))
        navigationItem.rightBarButtonItem = completeButton

        nicknameTextField.delegate = self
    }

    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide

        profileIcon.addToSuperview(view)
        profileIconSettingButton.addToSuperview(view)
        nicknameLabel.addToSuperview(view)
        nicknameTextField.addToSuperview(view)
        divider.addToSuperview(view)
        nicknameCountStackView.addToSuperview(view)
        [UIView(), nicknameCountLabel].forEach {
            nicknameCountStackView.addArrangedSubview($0)
        }

        profileIcon
            .centerX(equalTo: view.centerXAnchor)
            .size(
                width: view.bounds.width / ProfileLayoutConstant.profileIconWidthDivide,
                height: view.bounds.width / ProfileLayoutConstant.profileIconWidthDivide)
            .top(equalTo: safeArea.topAnchor, constant: ProfileLayoutConstant.profileIconTopMargin)

        profileIconSettingButton
            .trailing(equalTo: profileIcon.trailingAnchor, constant: 0)
            .bottom(equalTo: profileIcon.bottomAnchor, inset: ProfileLayoutConstant.profileIconSettingButtonBottomMargin)
            .size(
                width: ProfileLayoutConstant.profileIconSettingButtonSize,
                height: ProfileLayoutConstant.profileIconSettingButtonSize)

        nicknameLabel
            .centerX(equalTo: view.centerXAnchor)
            .top(equalTo: profileIcon.bottomAnchor, constant: ProfileLayoutConstant.nicknameLabelTopMargin)
            .horizontalEdges(equalTo: view, inset: horizontalMargin)

        nicknameTextField
            .centerX(equalTo: view.centerXAnchor)
            .top(equalTo: nicknameLabel.bottomAnchor, constant: ProfileLayoutConstant.nicknameTextFieldTopMargin)
            .horizontalEdges(equalTo: view, inset: horizontalMargin)

        divider
            .centerX(equalTo: view.centerXAnchor)
            .top(equalTo: nicknameTextField.bottomAnchor, constant: ProfileLayoutConstant.dividerTopMargin)
            .horizontalEdges(equalTo: view, inset: horizontalMargin)

        nicknameCountStackView
            .centerX(equalTo: view.centerXAnchor)
            .top(equalTo: divider.bottomAnchor, constant: ProfileLayoutConstant.nicknameCountStackViewTopMargin)
            .horizontalEdges(equalTo: view, inset: horizontalMargin)
    }

    private func bind() {
        viewModel.output.profile
            .map { $0.nickname }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                guard let self else { return }
                self.updateProfileState(nickname: nickname)
            }
            .store(in: &cancellables)
    }

    private func updateProfileState(nickname: String) {
        nicknameCountLabel.text = "\(nickname.count)/\(nicknameMaxCount)"
        if !nickname.isEmpty {
            completeButton.isEnabled = true
            completeButton.tintColor = .airplainBlue
        } else {
            completeButton.isEnabled = false
            completeButton.tintColor = .gray400
        }
    }

    @objc private func dismissView() {
        dismiss(animated: true)
    }

    @objc private func saveProfile() {
        viewModel.action(input: .saveProfile)
    }
}

// MARK: - UITextFieldDelegate
extension ProfileViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if range.location == 0 && string == " " {
            return false
        }
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)

        if updatedText.count <= nicknameMaxCount {
            viewModel.action(input: .updateProfileNickname(nickname: updatedText))
            return true
        }
        return false
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.action(input: .updateProfileNickname(nickname: ""))
        return true
    }
}
