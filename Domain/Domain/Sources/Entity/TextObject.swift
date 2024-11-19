//
//  TextObject.swift
//  Domain
//
//  Created by 박승찬 on 11/13/24.
//

import Foundation

public class TextObject: WhiteboardObject {
    public var text: String

    public init(
        id: UUID,
        position: CGPoint,
        size: CGSize,
        text: String,
        selectedBy: Profile? = nil
    ) {
        self.text = text
        super.init(
            id: id,
            position: position,
            size: size,
            selectedBy: selectedBy)
    }
}
