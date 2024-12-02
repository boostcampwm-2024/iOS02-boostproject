//
//  TextObjectView.swift
//  Presentation
//
//  Created by 박승찬 on 11/13/24.
//

import Domain
import UIKit

final class TextObjectView: WhiteboardObjectView {
    private let textField: AirplainTextField = {
        let textField = AirplainTextField()
        textField.textAlignment = .center
        textField.textColor = .airplainBlack
        textField.backgroundColor = .clear
        textField.isUserInteractionEnabled = false

        return textField
    }()

    init(
        textObject: TextObject,
        textFieldDelegate: AirplaINTextFieldDelegate?
    ) {
        super.init(whiteboardObject: textObject)
        configureLayout()
        textField.airplainTextFieldDelegate = textFieldDelegate
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayout()
    }

    override func configureLayout() {
        textField
            .addToSuperview(self)
            .edges(equalTo: self)
        super.configureLayout()
    }

    override func update(with object: WhiteboardObject) {
        super.update(with: object)
        guard let textObject = object as? TextObject else { return }

        textField.text = textObject.text
    }

    override func configureEditable(isEditable: Bool) {
        super.configureEditable(isEditable: isEditable)
        textField.isUserInteractionEnabled = isEditable
        textField.resignFirstResponder()
    }
}
