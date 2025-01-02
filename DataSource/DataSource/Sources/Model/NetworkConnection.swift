//
//  NetworkConnection.swift
//  DataSource
//
//  Created by 최정인 on 11/7/24.
//

import Foundation

public struct NetworkConnection {
    public let id: UUID
    public let name: String
    public let info: [String: String]?

    public init(
        id: UUID,
        name: String,
        info: [String: String]?
    ) {
        self.id = id
        self.name = name
        self.info = info
    }
}

extension NetworkConnection: Equatable {
    public static func == (lhs: NetworkConnection, rhs: NetworkConnection) -> Bool {
        return lhs.id == rhs.id
    }
}

public struct RefactoredNetworkConnection: Codable {
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

extension RefactoredNetworkConnection: Hashable {
    public static func == (lhs: RefactoredNetworkConnection, rhs: RefactoredNetworkConnection) -> Bool {
        return lhs.id == rhs.id
    }
}

extension RefactoredNetworkConnection: CustomStringConvertible {
    public var description: String {
        return "ID: \(id), Name: \(name)"
    }
}
