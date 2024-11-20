//
//  DataInformationDTO.swift
//  DataSource
//
//  Created by 이동현 on 11/20/24.
//

import Foundation

public struct DataInformationDTO: Codable {
    public let identifier: UUID
    public let type: AirplaINDataType
}
