//
//  WhiteboardObjectViewFactoryable.swift
//  Presentation
//
//  Created by 이동현 on 11/12/24.
//
import Domain

protocol WhiteboardObjectViewFactoryable {
    func create(with whiteboardObject: WhiteboardObject) -> WhiteboardObjectView
}
