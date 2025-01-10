//
//  TextObject.swift
//  Domain
//
//  Created by 박승찬 on 11/13/24.
//

import Foundation

public class TextObject: WhiteboardObject {
    public private(set) var text: String

    private enum CodingKeys: String, CodingKey { case text }

    public init(
        id: UUID,
        centerPosition: CGPoint,
        size: CGSize,
        scale: CGFloat = 1,
        angle: CGFloat = 0,
        text: String,
        selectedBy: Profile? = nil
    ) {
        self.text = text
        super.init(
            id: id,
            centerPosition: centerPosition,
            size: size,
            scale: scale,
            angle: angle,
            selectedBy: selectedBy)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let text = try container.decode(String.self, forKey: .text)
        self.text = text
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try super.encode(to: encoder)
    }

    override func deepCopy() -> WhiteboardObject {
        return TextObject(
            id: id,
            centerPosition: centerPosition,
            size: size,
            scale: scale,
            angle: angle,
            text: text,
            selectedBy: selectedBy)
    }

    func update(text: String) {
        self.text = text
    }
}
