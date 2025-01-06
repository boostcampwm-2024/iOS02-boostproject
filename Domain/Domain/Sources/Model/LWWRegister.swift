//
//  LWWRegister.swift
//  Domain
//
//  Created by 박승찬 on 1/6/25.
//

actor LWWRegister {
    private var whiteboardObject: WhiteboardObject
    private var timestamp: Timestamp

    init(whiteboardObject: WhiteboardObject, timestamp: Timestamp) {
        self.whiteboardObject = whiteboardObject
        self.timestamp = timestamp
    }

    func merge(with updatedObject: WhiteboardObject, at updatedTimestamp: Timestamp) {
        if timestamp < updatedTimestamp { whiteboardObject = updatedObject }
    }
}
