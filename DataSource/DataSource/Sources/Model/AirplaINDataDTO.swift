//
//  AirplaINDataDTO.swift
//  DataSource
//
//  Created by 이동현 on 11/20/24.
//

import Foundation

public struct AirplaINDataDTO: Codable {
    public let id: UUID
    public let data: Data
    public let type: AirplaINDataType
    public let isDeleted: Bool

    public init(
        id: UUID,
        data: Data,
        type: AirplaINDataType,
        isDeleted: Bool
    ) {
        self.id = id
        self.data = data
        self.type = type
        self.isDeleted = isDeleted
    }
}
