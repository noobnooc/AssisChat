//
//  Color+Extensions.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import Foundation
import SwiftUI


// MARK: - Color assets
extension Color {
    // - MARK: Backgrounds
    static let background = Color(uiColor: .systemBackground)
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
    static let groupedBackground = Color(uiColor: .systemGroupedBackground)
    static let secondaryGroupedBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let tertiaryGroupedBackground = Color(uiColor: .tertiarySystemGroupedBackground)

    // - MARK: App Colors
    static let appBlue = Color("ColorBlue")
    static let appBrown = Color("ColorBrown")
    static let appGreen = Color("ColorGreen")
    static let appIndigo = Color("ColorIndigo")
    static let appOrange = Color("ColorOrange")
    static let appPink = Color("ColorPink")
    static let appRed = Color("ColorRed")
    static let appYellow = Color("ColorYellow")

    // - MARK: Accent
    static let originAccent = Color("AccentColor")
}

// MARK: - Work with hex string
extension Color {
    // Copy from https://stackoverflow.com/a/56874327
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // Copy from https://blog.eidinger.info/from-hex-to-color-and-back-in-swiftui#heading-from-color-to-hex-in-swiftui
    var hex: String {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return "000000"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}

// MARK: - RawRepresentable
extension Color: RawRepresentable {
    public var rawValue: String {
        self.hex
    }

    public init?(rawValue: String) {
        guard let color = Color(hex: rawValue) else {
            return nil
        }

        self = color
    }
}

