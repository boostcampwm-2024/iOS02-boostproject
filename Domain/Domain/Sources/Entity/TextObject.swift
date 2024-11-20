//
//  TextObject.swift
//  Domain
//
//  Created by 박승찬 on 11/13/24.
//

import Foundation

public class TextObject: WhiteboardObject {
    public var text: String

    private enum CodingKeys: String, CodingKey { case text }

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
}
