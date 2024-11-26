//
//  WhiteboardObjectViewFactoryable.swift
//  Presentation
//
//  Created by 이동현 on 11/12/24.
//
import Domain
import Foundation

public protocol WhiteboardObjectViewFactoryable {
    var whiteboardObjectViewDelegate: WhiteboardObjectViewDelegate? { get set }
    func create(with whiteboardObject: WhiteboardObject) -> WhiteboardObjectView?
}

public struct WhiteboardObjectViewFactory: WhiteboardObjectViewFactoryable {
    public weak var whiteboardObjectViewDelegate: WhiteboardObjectViewDelegate?

    public init() {}

    public func create(with whiteboardObject: WhiteboardObject) -> WhiteboardObjectView? {
        let whiteboardObjectView: WhiteboardObjectView?

        switch whiteboardObject {
        case let textObject as TextObject:
            whiteboardObjectView = TextObjectView(textObject: textObject)
        case let drawingObject as DrawingObject:
            whiteboardObjectView = DrawingObjectView(drawingObject: drawingObject)
        case let photoObject as PhotoObject:
            whiteboardObjectView = PhotoObjectView(photoObject: photoObject)

        default:
            whiteboardObjectView = nil
        }

        whiteboardObjectView?.delegate = whiteboardObjectViewDelegate
        return whiteboardObjectView
    }
}
