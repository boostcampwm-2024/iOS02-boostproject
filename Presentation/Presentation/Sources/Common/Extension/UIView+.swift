//
//  UIView+.swift
//  Presentation
//
//  Created by 최정인 on 11/11/24.
//

import UIKit

extension UIView {
    func addToSuperview(_ superview: UIView) -> Self {
        superview.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    func top(
        equalTo anchor: NSLayoutYAxisAnchor,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> Self {
        let constraint = self
            .topAnchor
            .constraint(equalTo: anchor, constant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return self
    }

    func top(
        equalTo anchor: NSLayoutYAxisAnchor,
        inset: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> Self {
        return self.top(
            equalTo: anchor,
            constant: inset,
            priority: priority)
    }

    func bottom(
        equalTo anchor: NSLayoutYAxisAnchor,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> Self {
        let constraint = self
            .bottomAnchor
            .constraint(equalTo: anchor, constant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return self
    }

    func bottom(
        equalTo anchor: NSLayoutYAxisAnchor,
        inset: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> Self {
        return self.bottom(
            equalTo: anchor,
            constant: -inset,
            priority: priority)
    }

    func leading(
        equalTo anchor: NSLayoutXAxisAnchor,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> Self {
        let constraint = self
            .leadingAnchor
            .constraint(equalTo: anchor, constant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return self
    }

    func leading(
        equalTo anchor: NSLayoutXAxisAnchor,
        inset: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> Self {
        return self.leading(
            equalTo: anchor,
            constant: inset,
            priority: priority)
    }

    func trailing(
        equalTo anchor: NSLayoutXAxisAnchor,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> Self {
        let constraint = self
            .trailingAnchor
            .constraint(equalTo: anchor, constant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return self
    }

    func trailing(
        equalTo anchor: NSLayoutXAxisAnchor,
        inset: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> Self {
        return self.trailing(
            equalTo: anchor,
            constant: -inset,
            priority: priority)
    }

    func width(equalTo constant: CGFloat, priority: UILayoutPriority = .required) -> Self {
        let constraint = self
            .widthAnchor
            .constraint(equalToConstant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return self
    }

    func height(equalTo constant: CGFloat, priority: UILayoutPriority = .required) -> Self {
        let constraint = self
            .heightAnchor
            .constraint(equalToConstant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return self
    }

    func size(
        width: CGFloat,
        height: CGFloat,
        priority: UILayoutPriority = .required
    ) -> Self {
        return self
            .width(equalTo: width, priority: priority)
            .height(equalTo: height, priority: priority)
    }

    func centerX(
        equalTo anchor: NSLayoutXAxisAnchor,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> Self {
        let constraint = self
            .centerXAnchor
            .constraint(equalTo: anchor, constant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return self
    }

    func centerY(
        equalTo anchor: NSLayoutYAxisAnchor,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> Self {
        let constraint = self
            .centerYAnchor
            .constraint(equalTo: anchor, constant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return self
    }

    func center(in view: UIView, priority: UILayoutPriority = .required) -> Self {
        return self
            .centerX(equalTo: view.centerXAnchor, priority: priority)
            .centerY(equalTo: view.centerYAnchor, priority: priority)
    }

    func edges(
        equalTo view: UIView,
        inset: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> Self {
        return self
            .top(
                equalTo: view.topAnchor,
                inset: inset,
                priority: priority)
            .leading(
                equalTo: view.leadingAnchor,
                inset: inset,
                priority: priority)
            .bottom(
                equalTo: view.bottomAnchor,
                inset: inset,
                priority: priority)
            .trailing(
                equalTo: view.trailingAnchor,
                inset: inset,
                priority: priority)
    }

    func horizontalEdges(
        equalTo view: UIView,
        inset: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> Self {
        return self
            .leading(
                equalTo: view.leadingAnchor,
                inset: inset,
                priority: priority)
            .trailing(
                equalTo: view.trailingAnchor,
                inset: inset,
                priority: priority)
    }

    func verticalEdges(
        equalTo view: UIView,
        inset: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> Self {
        return self
            .top(
                equalTo: view.topAnchor,
                inset: inset,
                priority: priority)
            .bottom(
                equalTo: view.bottomAnchor,
                inset: inset,
                priority: priority)
    }
}
