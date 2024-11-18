//
//  AirplaINImageData.swift
//  Domain
//
//  Created by 이동현 on 11/18/24.
//

import Foundation

public struct AirplaINImageData {
    let width: CGFloat
    let height: CGFloat
    let imageData: Data

    public init(
        width: CGFloat,
        height: CGFloat,
        imageData: Data
    ) {
        self.width = width
        self.height = height
        self.imageData = imageData
    }
}
