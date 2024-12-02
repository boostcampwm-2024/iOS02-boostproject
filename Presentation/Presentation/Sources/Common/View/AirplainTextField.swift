//
//  AirplainTextField.swift
//  Presentation
//
//  Created by 이동현 on 12/2/24.
//

import UIKit

public protocol AirplaINTextFieldDelegate: AnyObject, UITextFieldDelegate {
    func airplainTextFieldDidChange(_ textField: AirplainTextField)
}

public final class AirplainTextField: UITextField {
    weak var airplainTextFieldDelegate: AirplaINTextFieldDelegate? {
        didSet {
            delegate = airplainTextFieldDelegate
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAttribute()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureAttribute()
    }

    private func configureAttribute() {
        configurePlaceHolder()

        self.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.airplainTextFieldDelegate?.airplainTextFieldDidChange(self)
            },
            for: .editingChanged)

        self.addAction(
            UIAction { [weak self] _ in
                self?.attributedPlaceholder = nil
            },
            for: .editingDidBegin)

        self.addAction(
            UIAction { [weak self] _ in
                self?.configurePlaceHolder()
            },
            for: .editingDidEnd)
    }

    private func configurePlaceHolder() {
        let placeholderText = "Hello, AirplaIN"
        let placeholderAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.airplainBlack]
        self.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
    }
}
