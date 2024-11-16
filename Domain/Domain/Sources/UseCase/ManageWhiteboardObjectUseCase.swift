//
//  ManageWhiteboardObjectUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/16/24.
//

import Combine

public final class ManageWhiteboardObjectUseCase: ManageWhiteboardObjectUseCaseInterface {
    public var addedObjectPublisher: AnyPublisher<WhiteboardObject, Never>
    public var updatedObjectPublisher: AnyPublisher<WhiteboardObject, Never>
    public var removedObjectPublisher: AnyPublisher<WhiteboardObject, Never>
    private var whiteboardObjects: [WhiteboardObject]

    private let addedWhiteboardSubject: PassthroughSubject<WhiteboardObject, Never>
    private let updatedWhiteboardSubject: PassthroughSubject<WhiteboardObject, Never>
    private let removedWhiteboardSubject: PassthroughSubject<WhiteboardObject, Never>

    public init() {
        addedWhiteboardSubject = PassthroughSubject<WhiteboardObject, Never>()
        updatedWhiteboardSubject = PassthroughSubject<WhiteboardObject, Never>()
        removedWhiteboardSubject = PassthroughSubject<WhiteboardObject, Never>()

        whiteboardObjects = []

        addedObjectPublisher = addedWhiteboardSubject.eraseToAnyPublisher()
        updatedObjectPublisher = updatedWhiteboardSubject.eraseToAnyPublisher()
        removedObjectPublisher = removedWhiteboardSubject.eraseToAnyPublisher()
    }

    public func addObject(whiteboardObject: WhiteboardObject) -> Bool {
        guard !whiteboardObjects.contains(whiteboardObject) else { return  false }
        whiteboardObjects.append(whiteboardObject)
        addedWhiteboardSubject.send(whiteboardObject)
        return true
    }

    public func updateObject(whiteboardObject: WhiteboardObject) -> Bool {
        guard let index = whiteboardObjects.firstIndex(where: { $0 == whiteboardObject }) else { return false }
        whiteboardObjects[index] = whiteboardObject
        updatedWhiteboardSubject.send(whiteboardObject)
        return true
    }

    public func removeObject(whiteboardObject: WhiteboardObject) -> Bool {
        guard whiteboardObjects.contains(whiteboardObject) else { return false }
        whiteboardObjects.removeAll { $0 == whiteboardObject }
        removedWhiteboardSubject.send(whiteboardObject)
        return true
    }
}
