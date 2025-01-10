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
    private let whiteboardObjectSet: WhiteboardObjectSetInterface

    public init(whiteboardObjectSet: WhiteboardObjectSetInterface, textFieldDefaultSize: CGSize) {
        self.whiteboardObjectSet = whiteboardObjectSet
        self.textFieldDefaultSize = textFieldDefaultSize
    }

    public func addText(centerPoint point: CGPoint) -> TextObject {
        return TextObject(
            id: UUID(),
            centerPosition: validPoint(point: point),
            size: textFieldDefaultSize,
            text: "")
    }

    public func editText(id: UUID, text: String) async {
        guard
            let textObject = await whiteboardObjectSet
                .fetchObjectByID(id: id) as? TextObject
        else { return }

        textObject.update(text: text)
        await whiteboardObjectSet.update(object: textObject)
    }

    private func validPoint(point: CGPoint) -> CGPoint {
        return CGPoint(
            x: point.x < 0 ? 0: point.x,
            y: point.y < 0 ? 0: point.y)
    }
}
