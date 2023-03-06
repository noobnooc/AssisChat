//
//  Chat+CoreDataClass.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//
//

import Foundation
import CoreData
import SwiftUI

@objc(Chat)
public class Chat: NSManagedObject {
    var name: String {
        return rawName ?? "[UNKNOWN]"
    }

    var temperature: Temperature {
        return Temperature(rawValue: rawTemperature) ?? .balanced
    }

    var systemMessage: String? {
        return rawSystemMessage
    }

    var messageCount: Int {
        return messages.count
    }

    var messages: [Message] {
        let messages = rMessages?.allObjects as? [Message] ?? []

        return messages.sorted { m1, m2 in
            m1.timestamp < m2.timestamp
        }
    }

    var orderTimestamp: Date {
        return  rawCreatedAt ?? Date()
    }

    public override func awakeFromInsert() {
        self.rawCreatedAt = Date()
    }
}

// MARK: - Temperature

extension Chat {
    enum Temperature: Float {
        case creative = 2
        case balanced = 1
        case precise = 0
    }
}

// MARK: - Icon
extension Chat {
    var icon: Icon {
        guard let iconString = self.rawIcon else { return Icon.default }

        return Icon(rawValue: iconString) ?? Icon.default
    }

    enum Icon: RawRepresentable, Hashable, Identifiable {
        case symbol(String)

        static let `default` = Self.symbols.first!

        private static let SYMBOL_PREFIX = "symbol:"

        // MARK: - RawRepresentable
        typealias RawValue = String

        init?(rawValue: String) {
            guard let icon = Self.symbols.first(where: { rawValue == $0.rawValue }) else {
                return nil
            }

            self = icon
        }

        var rawValue: String {
            switch self {
            case .symbol(let symbol): return Self.SYMBOL_PREFIX + symbol
            }
        }

        // MARK: - Identifiable
        var id: String {
            rawValue
        }

        // MARK: - Content

        var image: Image {
            switch self {
            case .symbol(let symbol): return Image(systemName: symbol)
            }
        }

        static let symbols: [Icon] = [
            .symbol("text.book.closed"),
            .symbol("house"),
            .symbol("flag"),
            .symbol("tv"),
            .symbol("car"),
            .symbol("person.2"),
            .symbol("baseball"),
            .symbol("newspaper"),
            .symbol("bell"),
            .symbol("graduationcap"),
            .symbol("cart"),
            .symbol("creditcard"),
            .symbol("paintbrush"),
            .symbol("lightbulb"),
            .symbol("briefcase"),
            .symbol("die.face.5"),
            .symbol("gift"),
            .symbol("hammer"),
            .symbol("gamecontroller"),
            .symbol("tent"),
            .symbol("light.beacon.max"),
            .symbol("party.popper"),
            .symbol("tshirt"),
            .symbol("headphones"),
            .symbol("facemask"),
            .symbol("teddybear"),
            .symbol("fork.knife"),
            .symbol("camera"),
            .symbol("guitars"),
            .symbol("sailboat")
        ]
    }
}

// MARK: - Color
extension Chat {
    var color: Color? {
        get {
            guard let colorString = rawColor else {
                return nil
            }

            return Color(rawValue: colorString) ?? .default
        }
        set {
            rawColor = newValue?.rawValue
        }
    }

    /**
     Color using in SwiftUI
     */
    var uiColor: SwiftUI.Color {
        color?.color ?? Color.default.color
    }

    enum Color: Equatable, RawRepresentable {
        static let `default` = Self.green

        static let customPrefix = "custom:"
        static let builtIns: [Color] = [
            .green,
            .yellow,
            .orange,
            .brown,
            .red,
            .pink,
            .purple,
            .indigo,
            .blue,
            .cyan,
        ]

        // 配置一些默认颜色，方便后期与主题同步调整对应颜色而不是固定的颜色值
        case blue
        case brown
        case cyan
        case green
        case indigo
        case orange
        case pink
        case purple
        case red
        case yellow
        case custom(color: SwiftUI.Color)

        typealias RawValue = String

        init?(rawValue: String) {
            if rawValue.starts(with: Self.customPrefix) {
                let hexString = String(rawValue.dropFirst(Self.customPrefix.count))

                guard let color = SwiftUI.Color(hex: hexString) else { return nil }
                self = .custom(color: color)
            } else if let builtIn = Self.builtIns.first(where: { rawValue == $0.rawValue}) {
                self = builtIn
            } else {
                return nil
            }
        }

        var rawValue: String {
            switch self {
            case .blue: return "blue"
            case .brown: return "brown"
            case .cyan: return "cyan"
            case .green: return "green"
            case .indigo: return "indigo"
            case .orange: return "orange"
            case .pink: return "pink"
            case .purple: return "purple"
            case .red: return "red"
            case .yellow: return "yellow"
            case .custom(color: let color): return Self.customPrefix + color.hex
            }
        }

        var color: SwiftUI.Color {
            switch self {
            case .blue: return .appBlue
            case .brown: return .appBrown
            case .cyan: return .appCyan
            case .green: return .appGreen
            case .indigo: return .appIndigo
            case .orange: return .appOrange
            case .pink: return .appPink
            case .purple: return .appPurple
            case .red: return .appRed
            case .yellow: return .appYellow
            case .custom(color: let color): return color
            }
        }
    }
}
