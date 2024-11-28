//
//  PublisherInfo.swift
//  DataSource
//
//  Created by 최다경 on 11/26/24.
//
import Foundation

struct PublisherInfo: Codable {
    let publishingCandidate: NetworkConnection
    let IDs: [UUID]
    let connections: [NetworkConnection]
    let participantsInfo: [String: String]

    public init(publishingCandidate: NetworkConnection,
                IDs: [UUID],
                connections: [NetworkConnection],
                participantsInfo: [String: String]) {
        self.publishingCandidate = publishingCandidate
        self.IDs = IDs
        self.connections = connections
        self.participantsInfo = participantsInfo
    }
}
