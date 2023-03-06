//
//  Haptics.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import Foundation
import UIKit


struct Haptics {
    static func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle, intensity: Float = 1) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred(intensity: CGFloat(intensity))
    }

    static func veryLight() {
        play(.rigid, intensity: 0.8)
    }
}
