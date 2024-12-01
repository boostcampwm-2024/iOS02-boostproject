//
//  PhotoObject.swift
//  Domain
//
//  Created by 이동현 on 11/18/24.
//

import Foundation

public final class PhotoObject: WhiteboardObject {
    public init(
        id: UUID,
        centerPosition: CGPoint,
        size: CGSize,
        scale: CGFloat = 1,
        angle: CGFloat = 0,
        photoURL: URL,
        selectedBy: Profile? = nil
    ) {
        super.init(
            id: id,
            centerPosition: centerPosition,
            size: size,
            scale: scale,
            angle: angle,
            selectedBy: selectedBy)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
