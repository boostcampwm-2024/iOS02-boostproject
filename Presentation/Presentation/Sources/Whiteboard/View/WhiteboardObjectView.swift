//
//  WhiteboardObjectView.swift
//  Presentation
//
//  Created by 이동현 on 11/12/24.
//
import Domain
import UIKit

class WhiteboardObjectView: UIView {
    init(whiteboardObject: WhiteboardObject) {
        let frame = CGRect(origin: whiteboardObject.position, size: whiteboardObject.size)
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
