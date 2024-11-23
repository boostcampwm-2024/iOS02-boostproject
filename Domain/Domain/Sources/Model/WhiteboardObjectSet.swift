//
//  WhiteboardObjectStorage.swift
//  Domain
//
//  Created by 이동현 on 11/22/24.
//

import Foundation

actor WhiteboardObjectSet {
    private var whiteboardObjects: Set<WhiteboardObject> = []

    func contains(object: WhiteboardObject) -> Bool {
        return whiteboardObjects.contains(object)
    }

    func insert(object: WhiteboardObject) {
        whiteboardObjects.insert(object)
    }

    func remove(object: WhiteboardObject) {
        whiteboardObjects.remove(object)
    }

    func update(object: WhiteboardObject) {
        remove(object: object)
        insert(object: object)
    }

    func fetchObjectByID(id: UUID) -> WhiteboardObject? {
        return whiteboardObjects.first { $0.id == id }
    }
}
