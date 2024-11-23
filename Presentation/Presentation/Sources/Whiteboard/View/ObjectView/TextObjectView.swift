//
//  TextObjectView.swift
//  Presentation
//
//  Created by 박승찬 on 11/13/24.
//

import Domain
import UIKit

final class TextObjectView: WhiteboardObjectView {
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Hello AirplaIN"
        return textField
    }()

    init(textObject: TextObject) {
        super.init(whiteboardObject: textObject)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    private func configureAttribute() {
        textField.delegate = self
        textField.backgroundColor = .clear
    }

    private func configureLayout() {
        textField
            .addToSuperview(self)
            .edges(equalTo: self)
    }

    override func update(with object: WhiteboardObject) {
        super.update(with: object)
        guard let textObject = object as? TextObject else { return }
        textField.text = textObject.text
    }
}

extension TextObjectView: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let maxLength = 15
        guard let text = textField.text else { return true }
        let newlength = text.count + string.count - range.length
        return newlength < maxLength
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
