//
//  Whiteboard.swift
//  Domain
//
//  Created by 최다경 on 11/11/24.
//
import Foundation

public struct Whiteboard: Hashable {
    public let ID: UUID
    public let name: String
    public let participantIcons: [ProfileIcon]

    // TODO: - 수정
    public var objects: [WhiteboardObject]

    public init(
        id: UUID,
        name: String,
        participantIcons: [ProfileIcon],
        objects: [WhiteboardObject] = []
    ) {
        self.ID = id
        self.name = name
        self.participantIcons = participantIcons
        self.objects = objects
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ID)
    }
}
