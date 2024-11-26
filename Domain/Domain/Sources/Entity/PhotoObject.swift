//
//  PhotoObject.swift
//  Domain
//
//  Created by 이동현 on 11/18/24.
//

import Foundation

public final class PhotoObject: WhiteboardObject {
    public let photoURL: URL

    private enum CodingKeys: String, CodingKey { case photoURL }

    public init(
        id: UUID,
        centerPosition: CGPoint,
        size: CGSize,
        scale: CGFloat = 1,
        angle: CGFloat = 0,
        photoURL: URL,
        selectedBy: Profile? = nil
    ) {
        self.photoURL = photoURL
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
        let photoURL = try container.decode(URL.self, forKey: .photoURL)
        self.photoURL = photoURL
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(photoURL, forKey: .photoURL)
        try super.encode(to: encoder)
    }
}
