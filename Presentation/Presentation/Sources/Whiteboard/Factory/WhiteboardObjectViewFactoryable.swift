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
    var textViewDelegate: UITextViewDelegate? { get set }
    var gameObjectDelegate: GameObjectDelegate? { get set }
    func create(with whiteboardObject: WhiteboardObject) -> WhiteboardObjectView?
}

public struct WhiteboardObjectViewFactory: WhiteboardObjectViewFactoryable {
    public weak var whiteboardObjectViewDelegate: WhiteboardObjectViewDelegate?
    public weak var textViewDelegate: UITextViewDelegate?
    public weak var gameObjectDelegate: GameObjectDelegate?

    public init() {}

    public func create(with whiteboardObject: WhiteboardObject) -> WhiteboardObjectView? {
        let whiteboardObjectView: WhiteboardObjectView?

        switch whiteboardObject {
        case let textObject as TextObject:
            whiteboardObjectView = TextObjectView(textObject: textObject, textViewDelegate: textViewDelegate)
        case let drawingObject as DrawingObject:
            whiteboardObjectView = DrawingObjectView(drawingObject: drawingObject)
        case let photoObject as PhotoObject:
            whiteboardObjectView = PhotoObjectView(photoObject: photoObject)
        case let gameObject as GameObject:
            whiteboardObjectView = GameObjectView(gameObject: gameObject, gameObjectDelegate: gameObjectDelegate)
        default:
            whiteboardObjectView = nil
        }

        whiteboardObjectView?.delegate = whiteboardObjectViewDelegate
        return whiteboardObjectView
    }
}
