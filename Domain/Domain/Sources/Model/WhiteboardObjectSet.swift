//
//  WhiteboardObjectStorage.swift
//  Domain
//
//  Created by 이동현 on 11/22/24.
//

import Foundation

public actor WhiteboardObjectSet: WhiteboardObjectSetInterface {
    private var whiteboardObjects: Set<WhiteboardObject>

    public init() {
        whiteboardObjects = []
    }

    public func contains(object: WhiteboardObject) -> Bool {
        return whiteboardObjects.contains(object)
    }

    public func insert(object: WhiteboardObject) {
        whiteboardObjects.insert(object)
    }

    public func remove(object: WhiteboardObject) {
        whiteboardObjects.remove(object)
    }

    public func update(object: WhiteboardObject) {
        remove(object: object)
        insert(object: object)
    }

    public func fetchObjectByID(id: UUID) -> WhiteboardObject? {
        return whiteboardObjects.first { $0.id == id }
    }

    public func fetchAll() async -> [WhiteboardObject] {
        return Array(whiteboardObjects.sorted { $0.updatedAt < $1.updatedAt })
    }
}
