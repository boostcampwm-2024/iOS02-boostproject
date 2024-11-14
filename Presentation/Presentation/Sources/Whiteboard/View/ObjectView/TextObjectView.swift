//
//  TextObjectView.swift
//  Presentation
//
//  Created by 박승찬 on 11/13/24.
//

import Domain
import UIKit

final class TextObjectView: WhiteboardObjectView {
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Hello AirplaIN"
        return textField
    }()

    let textObject: TextObject

    init(textObject: TextObject) {
        self.textObject = textObject
        super.init(whiteboardObject: textObject)

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

    private func configureLayout() {
        textField
            .addToSuperview(self)
            .edges(equalTo: self)
    }
}
