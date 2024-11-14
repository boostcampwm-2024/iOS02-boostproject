//
//  Whiteboard.swift
//  Domain
//
//  Created by 최다경 on 11/11/24.
//
import Foundation

public struct Whiteboard {
    public let name: String

    // TODO: - 수정
    public var objects: [WhiteboardObject]

    public init(
        name: String,
        objects: [WhiteboardObject] = []
    ) {
        self.name = name
        self.objects = objects
    }
}
