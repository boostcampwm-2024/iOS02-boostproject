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
        return TextObject(
            id: UUID(),
            centerPosition: point,
            size: textFieldDefaultSize,
            text: "")
    }
}
