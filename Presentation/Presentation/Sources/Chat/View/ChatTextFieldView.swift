//
//  ChatTextFieldView.swift
//  Presentation
//
//  Created by 박승찬 on 11/25/24.
//

import UIKit

protocol ChatTextFieldViewDelegate: AnyObject, UITextFieldDelegate {
    func chatTextFieldView(_ sender: ChatTextFieldView, sendMessage: String)
}

final class ChatTextFieldView: UIView {
    private enum ChatTextFieldLayoutConstant {
        static let sendButtonSize: CGFloat = 40
        static let sendButtonTraillingInset: CGFloat = 8
        static let sendButtonImageSize: CGFloat = 20
        static let textFieldLeadingInset: CGFloat = 20
        static let textFieldBorderWidth: CGFloat = 1
        static let textFieldCornerRadius: CGFloat = 20
    }

    private let textField: UITextField = {
        let uiTextField = UITextField()
        uiTextField.returnKeyType = .send
        uiTextField.borderStyle = .none
        uiTextField.placeholder = "메시지 입력"

        return uiTextField
    }()

    private let sendButton: UIButton = {
        let button = UIButton()
        var buttonConfiguration = UIButton.Configuration.plain()
        let imageConfiguration = UIImage
            .SymbolConfiguration(
                pointSize: ChatTextFieldLayoutConstant.sendButtonImageSize)
        buttonConfiguration.image = UIImage(systemName: "arrow.up.circle.fill")
        buttonConfiguration.preferredSymbolConfigurationForImage = imageConfiguration
        button.configuration = buttonConfiguration
        button.tintColor = .airplainBlue

        return button
    }()

    private let backgroundView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.gray500.cgColor
        view.layer.borderWidth = ChatTextFieldLayoutConstant.textFieldBorderWidth
        view.layer.cornerRadius = ChatTextFieldLayoutConstant.textFieldCornerRadius

        return view
    }()

    weak var delegate: ChatTextFieldViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        configureButtonAction()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayout()
        configureButtonAction()
    }

    private func configureLayout() {
        backgroundView
            .addToSuperview(self)
            .edges(equalTo: self)

        sendButton
            .addToSuperview(self)
            .centerY(equalTo: self.centerYAnchor)
            .size(width: ChatTextFieldLayoutConstant.sendButtonSize,
                  height: ChatTextFieldLayoutConstant.sendButtonSize)
            .trailing(
                equalTo: self.trailingAnchor,
                inset: ChatTextFieldLayoutConstant.sendButtonTraillingInset)

        textField
            .addToSuperview(self)
            .verticalEdges(equalTo: self)
            .leading(equalTo: self.leadingAnchor,
                     inset: ChatTextFieldLayoutConstant.textFieldLeadingInset)
            .trailing(equalTo: sendButton.leadingAnchor, inset: 0)
    }

    private func configureButtonAction() {
        let sendAction = UIAction { [weak self] _ in
            guard
                let message = self?.textField.text,
                !message.isEmpty,
                let self
            else { return }
            delegate?.chatTextFieldView(self, sendMessage: message)
            textField.text = ""
        }
        sendButton.addAction(sendAction, for: .touchUpInside)
    }

    public func configureDelegate(delegate: ChatTextFieldViewDelegate) {
        textField.delegate = delegate
        self.delegate = delegate
    }
}
