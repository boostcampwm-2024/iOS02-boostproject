//
//  LWWRegister.swift
//  Domain
//
//  Created by 박승찬 on 1/6/25.
//

import Foundation

public class LWWRegister {
    private(set) var whiteboardObject: WhiteboardObject
    private var timestamp: Timestamp
    private var serialQueue: DispatchQueue

    init(whiteboardObject: WhiteboardObject, timestamp: Timestamp) {
        self.whiteboardObject = whiteboardObject
        self.timestamp = timestamp
        serialQueue = DispatchQueue(label: "serial")
    }

    func merge(register: LWWRegister) {
        serialQueue.async {
            if self.timestamp < register.timestamp {
                self.whiteboardObject = register.whiteboardObject
                self.timestamp = register.timestamp
            }
        }
    }
}

extension LWWRegister: Hashable {
    public static func == (lhs: LWWRegister, rhs: LWWRegister) -> Bool {
        lhs.whiteboardObject == rhs.whiteboardObject
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(whiteboardObject)
    }
}

extension LWWRegister: Comparable {
    public static func < (lhs: LWWRegister, rhs: LWWRegister) -> Bool {
        lhs.timestamp < rhs.timestamp
    }
}
