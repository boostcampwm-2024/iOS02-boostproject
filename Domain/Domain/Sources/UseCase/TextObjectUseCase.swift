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

    public init(textFieldDefaultSize: CGSize) {
        self.textFieldDefaultSize = textFieldDefaultSize
    }

    public func addText(scrollViewOffset: CGPoint, viewSize: CGSize) -> TextObject {
        let positionX = scrollViewOffset.x + viewSize.width / 3
        let positionY = scrollViewOffset.y + viewSize.height / 3
        let position = CGPoint(x: positionX, y: positionY)
        return TextObject(
            id: UUID(),
            position: position,
            size: textFieldDefaultSize,
            text: "")
    }
}
