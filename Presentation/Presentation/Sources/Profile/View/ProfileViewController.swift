//
//  ProfileViewController.swift
//  Presentation
//
//  Created by 최정인 on 11/13/24.
//

import Combine
import Domain
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
    private let profileIcon = ProfileIconView()

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

    private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "닉네임을 입력해주세요."
        textField.textColor = .airplainBlack
        textField.clearButtonMode = .whileEditing
        textField.font = AirplainFont.Body2
        return textField
    }()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .gray500
        view.height(equalTo: ProfileLayoutConstant.dividerHeight)
        return view
    }()

    private let nicknameCountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()

    private let nicknameCountLabel: UILabel = {
        let label = UILabel()
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

    public override func viewDidLoad() {
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

        profileIconSettingButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.showSelectProfileIconView()
            }, for: .touchUpInside)

        nicknameTextField.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.textFieldDidChange(self.nicknameTextField)
            }, for: .editingChanged)

        nicknameTextField.delegate = self
    }

    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide

        [UIView(), nicknameCountLabel].forEach {
            nicknameCountStackView.addArrangedSubview($0)
        }

        profileIcon
            .addToSuperview(view)
            .centerX(equalTo: view.centerXAnchor)
            .size(
                width: view.bounds.width / ProfileLayoutConstant.profileIconWidthDivide,
                height: view.bounds.width / ProfileLayoutConstant.profileIconWidthDivide)
            .top(equalTo: safeArea.topAnchor, constant: ProfileLayoutConstant.profileIconTopMargin)

        profileIconSettingButton
            .addToSuperview(view)
            .trailing(equalTo: profileIcon.trailingAnchor, constant: 0)
            .bottom(
                equalTo: profileIcon.bottomAnchor,
                inset: ProfileLayoutConstant.profileIconSettingButtonBottomMargin)
            .size(
                width: ProfileLayoutConstant.profileIconSettingButtonSize,
                height: ProfileLayoutConstant.profileIconSettingButtonSize)

        nicknameLabel
            .addToSuperview(view)
            .centerX(equalTo: view.centerXAnchor)
            .top(equalTo: profileIcon.bottomAnchor, constant: ProfileLayoutConstant.nicknameLabelTopMargin)
            .horizontalEdges(equalTo: view, inset: horizontalMargin)

        nicknameTextField
            .addToSuperview(view)
            .centerX(equalTo: view.centerXAnchor)
            .top(equalTo: nicknameLabel.bottomAnchor, constant: ProfileLayoutConstant.nicknameTextFieldTopMargin)
            .horizontalEdges(equalTo: view, inset: horizontalMargin)

        divider
            .addToSuperview(view)
            .centerX(equalTo: view.centerXAnchor)
            .top(equalTo: nicknameTextField.bottomAnchor, constant: ProfileLayoutConstant.dividerTopMargin)
            .horizontalEdges(equalTo: view, inset: horizontalMargin)

        nicknameCountStackView
            .addToSuperview(view)
            .centerX(equalTo: view.centerXAnchor)
            .top(equalTo: divider.bottomAnchor, constant: ProfileLayoutConstant.nicknameCountStackViewTopMargin)
            .horizontalEdges(equalTo: view, inset: horizontalMargin)
    }

    private func bind() {
        viewModel.output.profilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self else { return }
                self.updateProfileState(nickname: profile.nickname)
                self.profileIcon.configure(
                    profileIcon: profile.profileIcon,
                    profileIconSize: view.bounds.width / ProfileLayoutConstant.profileIconWidthDivide)
            }
            .store(in: &cancellables)
    }

    private func updateProfileState(nickname: String) {
        nicknameCountLabel.text = "\(nickname.count)/\(nicknameMaxCount)"
        nicknameTextField.text = nickname
        if !nickname.isEmpty {
            completeButton.isEnabled = true
            completeButton.tintColor = .airplainBlue
        } else {
            completeButton.isEnabled = false
            completeButton.tintColor = .gray400
        }
    }

    private func showSelectProfileIconView() {
        let selectProfileIconViewController = SelectProfileIconViewController(viewModel: viewModel)
        selectProfileIconViewController.modalPresentationStyle = .formSheet
        if let sheet = selectProfileIconViewController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(selectProfileIconViewController, animated: true)
    }

    @objc private func dismissView() {
        dismiss(animated: true)
    }

    @objc private func saveProfile() {
        viewModel.action(input: .saveProfile)
        dismiss(animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func textFieldDidChange(_ textField: UITextField) {
        guard let currentText = textField.text else { return }
        var updatedText = currentText

        if updatedText.count > nicknameMaxCount {
            updatedText = String(updatedText.prefix(nicknameMaxCount))
            textField.text = updatedText
        }
        viewModel.action(input: .updateProfileNickname(nickname: updatedText))
    }
}

// MARK: - UITextFieldDelegate
extension ProfileViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacters.isSuperset(of: characterSet) {
            return false
        }

        let koreanCharacterSet = CharacterSet(charactersIn: "가"..."힣")
        let containsKorean = updatedText.unicodeScalars.contains { koreanCharacterSet.contains($0) }

        let maxLength = containsKorean ? nicknameMaxCount + 1 : nicknameMaxCount
        if updatedText.count > maxLength {
            return false
        }

        return true
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.action(input: .updateProfileNickname(nickname: ""))
        return true
    }
}
