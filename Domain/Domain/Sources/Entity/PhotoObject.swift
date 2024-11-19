//
//  PhotoObject.swift
//  Domain
//
//  Created by 이동현 on 11/18/24.
//

import Foundation

public final class PhotoObject: WhiteboardObject {
    public let photoURL: URL

    public init(
        id: UUID,
        position: CGPoint,
        size: CGSize,
        photoURL: URL,
        selectedBy: Profile? = nil
    ) {
        self.photoURL = photoURL
        super.init(
            id: id,
            position: position,
            size: size,
            selectedBy: selectedBy)
    }
}
