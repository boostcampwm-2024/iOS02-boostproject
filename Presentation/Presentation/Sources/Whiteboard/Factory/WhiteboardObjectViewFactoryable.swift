//
//  WhiteboardObjectViewFactoryable.swift
//  Presentation
//
//  Created by 이동현 on 11/12/24.
//
import Domain
import UIKit

public protocol WhiteboardObjectViewFactoryable {
    var whiteboardObjectViewDelegate: WhiteboardObjectViewDelegate? { get set }
    var textFieldDelegate: AirplaINTextFieldDelegate? { get set }
    var gameObjectViewDelegate: GameObjectViewDelegate? { get set }
    var photoObjectViewDelegate: PhotoObjectViewDelegate? { get set }
    func create(with whiteboardObject: WhiteboardObject) -> WhiteboardObjectView?
}

public struct WhiteboardObjectViewFactory: WhiteboardObjectViewFactoryable {
    public weak var whiteboardObjectViewDelegate: WhiteboardObjectViewDelegate?
    public weak var textFieldDelegate: AirplaINTextFieldDelegate?
    public weak var gameObjectViewDelegate: GameObjectViewDelegate?
    public weak var photoObjectViewDelegate: PhotoObjectViewDelegate?

    public init() {}

    public func create(with whiteboardObject: WhiteboardObject) -> WhiteboardObjectView? {
        let whiteboardObjectView: WhiteboardObjectView?

        switch whiteboardObject {
        case let textObject as TextObject:
            whiteboardObjectView = TextObjectView(textObject: textObject, textFieldDelegate: textFieldDelegate)
        case let drawingObject as DrawingObject:
            whiteboardObjectView = DrawingObjectView(drawingObject: drawingObject)
        case let photoObject as PhotoObject:
            whiteboardObjectView = PhotoObjectView(
                photoObject: photoObject,
                photoObjectDelegate: photoObjectViewDelegate)
        case let gameObject as GameObject:
            whiteboardObjectView = GameObjectView(
                gameObject: gameObject,
                gameObjectViewDelegate: gameObjectViewDelegate)
        default:
            whiteboardObjectView = nil
        }

        whiteboardObjectView?.delegate = whiteboardObjectViewDelegate
        return whiteboardObjectView
    }
}
