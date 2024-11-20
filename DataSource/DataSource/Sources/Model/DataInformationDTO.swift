//
//  DataInformationDTO.swift
//  DataSource
//
//  Created by 이동현 on 11/20/24.
//

import Foundation

struct DataInformationDTO: Codable {
    let identifier: UUID
    let type: AirplaINDataType
}
