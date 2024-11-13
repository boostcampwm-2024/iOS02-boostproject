//
//  WhiteboardObjectViewFactoryable.swift
//  Presentation
//
//  Created by 이동현 on 11/12/24.
//
import Domain
import Foundation

protocol WhiteboardObjectViewFactoryable {
    func create(with whiteboardObject: WhiteboardObject) -> WhiteboardObjectView
}

struct WhiteboardObjectViewFactory: WhiteboardObjectViewFactoryable {
    func create(with whiteboardObject: WhiteboardObject) -> WhiteboardObjectView {
        switch whiteboardObject {
        case let textObject as TextObject:
            return TextObjectView(textObject: textObject)
        // TODO: 오브젝트 별 case 추가 예정
        default:
            break
        }

        return WhiteboardObjectView(
            whiteboardObject: WhiteboardObject(
                id: UUID(),
                position: .zero,
                size: .zero)
        )
    }
}
