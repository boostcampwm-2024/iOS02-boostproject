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

    public func removeAll() async {
        whiteboardObjects.removeAll()
    }

    public func update(object: WhiteboardObject) {
        remove(object: object)
        insert(object: object)
    }

    public func fetchObjectByID(id: UUID) -> WhiteboardObject? {
        guard let object = whiteboardObjects.first(where: { $0.id == id }) else { return nil }
        return object.deepCopy()
    }

    public func fetchAll() async -> [WhiteboardObject] {
        return whiteboardObjects
            .sorted { $0.updatedAt < $1.updatedAt }
            .map { $0.deepCopy() }
    }
}
