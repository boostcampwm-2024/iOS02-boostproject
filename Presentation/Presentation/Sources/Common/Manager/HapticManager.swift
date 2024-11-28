//
//  HapticManager.swift
//  Presentation
//
//  Created by 박승찬 on 11/28/24.
//

import Foundation
import UIKit

enum HapticManager {
    static func hapticNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    static func hapticImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
