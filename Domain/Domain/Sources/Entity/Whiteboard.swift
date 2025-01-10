//
//  Whiteboard.swift
//  Domain
//
//  Created by 최다경 on 11/11/24.
//
import Foundation

public struct Whiteboard: Hashable {
    public let id: UUID
    public let name: String
    public let participantIcons: [ProfileIcon]

    public init(
        id: UUID,
        name: String,
        participantIcons: [ProfileIcon]
    ) {
        self.id = id
        self.name = name
        self.participantIcons = participantIcons
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
