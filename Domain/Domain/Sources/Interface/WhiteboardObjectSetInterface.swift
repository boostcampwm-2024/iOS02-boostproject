//
//  WhiteboardObjectSetInterface.swift
//  Domain
//
//  Created by 이동현 on 11/26/24.
//

import Foundation

public protocol WhiteboardObjectSetInterface {
    func contains(object: WhiteboardObject) async -> Bool

    func insert(object: WhiteboardObject) async

    func remove(object: WhiteboardObject) async

    func update(object: WhiteboardObject) async

    func fetchObjectByID(id: UUID) async -> WhiteboardObject?
}
