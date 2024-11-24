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

    public func addText(centerPoint point: CGPoint, size: CGSize) -> TextObject {
        let positionX = point.x + size.width / 3
        let positionY = point.y + size.height / 3
        let centerPosition = CGPoint(
            x: positionX + size.width / 2,
            y: positionY + size.height / 2)
        return TextObject(
            id: UUID(),
            centerPosition: centerPosition,
            size: textFieldDefaultSize,
            text: "")
    }
}
