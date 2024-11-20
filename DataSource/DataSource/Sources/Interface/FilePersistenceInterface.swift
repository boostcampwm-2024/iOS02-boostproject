//
//  FilePersistenceInterface.swift
//  DataSource
//
//  Created by 박승찬 on 11/20/24.
//

import Foundation

public protocol FilePersistenceInterface {
    func save(dataInfo: DataInformationDTO, data: Data) -> URL?
}
