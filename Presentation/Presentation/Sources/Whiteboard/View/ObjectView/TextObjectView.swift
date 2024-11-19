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

    private let textObject: TextObject

    init(textObject: TextObject) {
        self.textObject = textObject
        super.init(whiteboardObject: textObject)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        self.textObject = TextObject(
            id: UUID(),
            position: .zero,
            size: .zero,
            text: "")
        super.init(coder: coder)
    }

    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    private func configureAttribute() {
        textField.delegate = self
    }

    private func configureLayout() {
        textField
            .addToSuperview(self)
            .edges(equalTo: self)
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
