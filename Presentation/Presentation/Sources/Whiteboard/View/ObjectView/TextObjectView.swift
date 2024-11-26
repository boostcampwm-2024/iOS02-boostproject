//
//  TextObjectView.swift
//  Presentation
//
//  Created by 박승찬 on 11/13/24.
//

import Domain
import UIKit

final class TextObjectView: WhiteboardObjectView {
    private let textView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .center
        textView.textColor = .airplainBlack
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.isUserInteractionEnabled = false
        return textView
    }()

    init(
        textObject: TextObject,
        textViewDelegate: UITextViewDelegate?
    ) {
        super.init(whiteboardObject: textObject)
        configureLayout()
        textView.delegate = textViewDelegate
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func configureLayout() {
        textView
            .addToSuperview(self)
            .edges(equalTo: self)
        super.configureLayout()
    }

    override func update(with object: WhiteboardObject) {
        super.update(with: object)
        guard let textObject = object as? TextObject else { return }

        textView.text = textObject.text
    }

    override func configureEditable(isEditable: Bool) {
        super.configureEditable(isEditable: isEditable)
        textView.isUserInteractionEnabled = isEditable
    }
}
