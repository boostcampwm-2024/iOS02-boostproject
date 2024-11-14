//
//  Whiteboard.swift
//  Domain
//
//  Created by 최다경 on 11/11/24.
//
import Foundation

public struct Whiteboard {
    let name: String

    // TODO: - 수정
    let objects: [WhiteboardObject]

    public init(
        name: String,
        peers: [UUID] = [],
        objects: [WhiteboardObject] = [],
        chats: [String] = []
    ) {
        self.name = name
        self.objects = objects
    }
}
