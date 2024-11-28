//
//  HapticManager.swift
//  Presentation
//
//  Created by 박승찬 on 11/28/24.
//

import Foundation
import UIKit

final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func hapticNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func hapticImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
