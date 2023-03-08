//
//  Haptics.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import Foundation

#if os(iOS)
import UIKit
#endif

struct Haptics {
    #if os(iOS)
    static func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle, intensity: Float = 1) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred(intensity: CGFloat(intensity))
    }
    #endif

    static func veryLight() {
        #if os(iOS)
        play(.rigid, intensity: 0.8)
        #endif
    }
}
