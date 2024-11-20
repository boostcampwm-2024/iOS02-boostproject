//
//  WhiteboardObjectViewFactoryable.swift
//  Presentation
//
//  Created by 이동현 on 11/12/24.
//
import Domain
import Foundation

protocol WhiteboardObjectViewFactoryable {
    func create(with whiteboardObject: WhiteboardObject) -> WhiteboardObjectView?
}

struct WhiteboardObjectViewFactory: WhiteboardObjectViewFactoryable {
    func create(with whiteboardObject: WhiteboardObject) -> WhiteboardObjectView? {
        switch whiteboardObject {
        case let textObject as TextObject:
            return TextObjectView(textObject: textObject)
        case let drawingObject as DrawingObject:
            return DrawingObjectView(drawingObject: drawingObject)
        case let photoObject as PhotoObject:
            return PhotoObjectView(photoObject: photoObject)
        default:
            break
        }

        return nil
    }
}
