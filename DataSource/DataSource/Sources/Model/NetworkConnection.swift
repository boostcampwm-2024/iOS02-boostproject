//
//  NetworkConnection.swift
//  DataSource
//
//  Created by 최정인 on 11/7/24.
//

import Foundation

public struct NetworkConnection: Codable {
    public let id: UUID
    public let name: String
    public let connectedPeerInfo: [String]

    public init(
        id: UUID,
        name: String,
        connectedPeerInfo: [String]
    ) {
        self.id = id
        self.name = name
        self.connectedPeerInfo = connectedPeerInfo
    }
}

extension NetworkConnection: Hashable {
    public static func == (lhs: NetworkConnection, rhs: NetworkConnection) -> Bool {
        return lhs.id == rhs.id
    }
}

extension NetworkConnection: CustomStringConvertible {
    public var description: String {
        return "ID: \(id), Name: \(name)"
    }
}
