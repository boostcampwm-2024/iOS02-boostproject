//
//  ChatTextFieldView.swift
//  Presentation
//
//  Created by 박승찬 on 11/25/24.
//

import UIKit

final class ChatTextFieldView: UIView {
    private enum ChatTextFieldLayoutConstant {
        static let sendButtonSize: CGFloat = 23
        static let sendButtonTraillingInset: CGFloat = 16
        static let textFieldLeadingInset: CGFloat = 20
    }

    private let textField: UITextField = {
        let uiTextField = UITextField()
        uiTextField.borderStyle = .none
        uiTextField.placeholder = "메시지 입력"

        return uiTextField
    }()

    private let sendButton: UIButton = {
        let button = UIButton()
        var buttonConfiguration = UIButton.Configuration.plain()
        buttonConfiguration.image = UIImage(systemName: "arrow.up.circle.fill")
        button.configuration = buttonConfiguration
        button.tintColor = .airplainBlue

        return button
    }()

    private let backgroundView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.gray500.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 20

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayout()
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
}
