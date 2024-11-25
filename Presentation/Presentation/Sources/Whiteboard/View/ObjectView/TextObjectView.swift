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

    init(textObject: TextObject) {
        super.init(whiteboardObject: textObject)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func configureAttribute() {
        textView.delegate = self
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
        print(textObject.text)
        textView.text = textObject.text
    }

    override func configureEditable(isEditable: Bool) {
        super.configureEditable(isEditable: isEditable)
        textView.isUserInteractionEnabled = isEditable
    }
}

extension TextObjectView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard text != "\n" else {
            textView.resignFirstResponder()
            return false
        }

        let maxLength = 15
        guard let originText = textView.text else { return true }
        let newlength = originText.count + text.count - range.length
        return newlength < maxLength
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // TODO: - TextView 수정 로직 추가
    }
}
