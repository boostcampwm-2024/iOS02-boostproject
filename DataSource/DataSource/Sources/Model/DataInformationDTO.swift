//
//  DataInformationDTO.swift
//  DataSource
//
//  Created by 이동현 on 11/20/24.
//

import Foundation

public struct DataInformationDTO: Codable {
    public let id: UUID
    public let type: AirplaINDataType
    public let isDeleted: Bool

    public init(
        id: UUID,
        type: AirplaINDataType,
        isDeleted: Bool
    ) {
        self.id = id
        self.type = type
        self.isDeleted = isDeleted
    }
}
