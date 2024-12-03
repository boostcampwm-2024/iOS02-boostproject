//
//  TextObjectUseCase.swift
//  Domain
//
//  Created by 박승찬 on 11/19/24.
//

import Combine
import Foundation

public final class TextObjectUseCase: TextObjectUseCaseInterface {
    private let textFieldDefaultSize: CGSize
    private let whiteboardObjectSet: WhiteboardObjectSet

    public init(whiteboardObjectSet: WhiteboardObjectSet, textFieldDefaultSize: CGSize) {
        self.whiteboardObjectSet = whiteboardObjectSet
        self.textFieldDefaultSize = textFieldDefaultSize
    }

    public func addText(centerPoint point: CGPoint, size: CGSize) -> TextObject {
        return TextObject(
            id: UUID(),
            centerPosition: point,
            size: textFieldDefaultSize,
            text: "")
    }

    public func editText(id: UUID, text: String) async {
        guard
            let texboardObject = await whiteboardObjectSet
                .fetchObjectByID(id: id) as? TextObject
        else { return }

        texboardObject.update(text: text)
        await whiteboardObjectSet.update(object: texboardObject)
    }
}
