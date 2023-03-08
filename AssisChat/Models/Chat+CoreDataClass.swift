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

    var messagePrefix: String? {
        return rawMessagePrefix
    }

    var isolated: Bool {
        return rawIsolated
    }

    var receiving: Bool {
        return messages.last?.receiving ?? false
    }

    var messages: [Message] {
        let messages = rMessages?.allObjects as? [Message] ?? []

        return messages.sorted { m1, m2 in
            m1.timestamp < m2.timestamp
        }
    }

    var orderTimestamp: Date {
        return derivedUpdatedAt ?? rawCreatedAt ?? Date()
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

        var display: LocalizedStringKey {
            switch self {
            case .creative: return LocalizedStringKey("CHAT_TEMPERATURE_CREATIVE")
            case .balanced: return LocalizedStringKey("CHAT_TEMPERATURE_BALANCED")
            case .precise: return LocalizedStringKey("CHAT_TEMPERATURE_PRECISE")
            }
        }

        var color: SwiftUI.Color {
            switch self {
            case .creative: return .appOrange
            case .balanced: return .appBlue
            case .precise: return .appGreen
            }
        }
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
            if rawValue.starts(with: Self.SYMBOL_PREFIX) {
                let symbolString = String(rawValue.dropFirst(Self.SYMBOL_PREFIX.count))

                self = .symbol(symbolString)
            } else {
                return nil
            }
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
            .symbol("bubble.left"),
            .symbol("book"),
            .symbol("book.closed"),
            .symbol("books.vertical"),
            .symbol("character.book.closed"),
            .symbol("text.book.closed"),
            .symbol("menucard"),
            .symbol("magazine"),
            .symbol("newspaper"),
            .symbol("bookmark"),
            .symbol("graduationcap"),
            .symbol("pencil.and.ruler"),
            .symbol("backpack"),
            .symbol("paperclip"),
            .symbol("link"),
            .symbol("dumbbell"),
            .symbol("soccerball"),
            .symbol("baseball"),
            .symbol("basketball"),
            .symbol("football"),
            .symbol("tennis.racket"),
            .symbol("tennisball"),
            .symbol("trophy"),
            .symbol("medal"),
            .symbol("umbrella"),
            .symbol("megaphone"),
            .symbol("shield"),
            .symbol("flag"),
            .symbol("flag.2.crossed"),
            .symbol("bell"),
            .symbol("tag"),
            .symbol("camera"),
            .symbol("gearshape"),
            .symbol("bag"),
            .symbol("cart"),
            .symbol("basket"),
            .symbol("creditcard"),
            .symbol("wallet.pass"),
            .symbol("wand.and.rays"),
            .symbol("die.face.2"),
            .symbol("pianokeys"),
            .symbol("paintbrush.pointed"),
            .symbol("wrench.adjustable"),
            .symbol("hammer"),
            .symbol("eyedropper.halffull"),
            .symbol("scroll"),
            .symbol("printer"),
            .symbol("scanner"),
            .symbol("handbag"),
            .symbol("briefcase"),
            .symbol("cross.case"),
            .symbol("theatermasks"),
            .symbol("puzzlepiece"),
            .symbol("lightbulb"),
            .symbol("fanblades"),
            .symbol("party.popper"),
            .symbol("balloon"),
            .symbol("popcorn"),
            .symbol("bed.double"),
            .symbol("chair.lounge"),
            .symbol("refrigerator"),
            .symbol("tent"),
            .symbol("house.lodge"),
            .symbol("house.and.flag"),
            .symbol("signpost.left"),
            .symbol("signpost.right"),
            .symbol("signpost.right.and.left"),
            .symbol("lock"),
            .symbol("lock.open"),
            .symbol("key"),
            .symbol("pin"),
            .symbol("powerplug"),
            .symbol("headphones"),
            .symbol("radio"),
            .symbol("guitars"),
            .symbol("stroller"),
            .symbol("sailboat"),
            .symbol("fuelpump"),
            .symbol("medical.thermometer"),
            .symbol("bandage"),
            .symbol("syringe"),
            .symbol("facemask"),
            .symbol("cross.vial"),
            .symbol("teddybear"),
            .symbol("tree"),
            .symbol("tshirt"),
            .symbol("ticket"),
            .symbol("crown"),
            .symbol("gamecontroller"),
            .symbol("paintpalette"),
            .symbol("cup.and.saucer"),
            .symbol("wineglass"),
            .symbol("birthday.cake"),
            .symbol("carrot"),
            .symbol("globe.desk"),
            .symbol("gift"),
            .symbol("binoculars"),
            .symbol("seal"),
            .symbol("hand.raised"),
            .symbol("sun.min"),
            .symbol("moon"),
            .symbol("sun.max"),
            .symbol("cloud"),
            .symbol("drop"),
            .symbol("mountain.2"),
            .symbol("hare"),
            .symbol("tortoise"),
            .symbol("lizard"),
            .symbol("bird"),
            .symbol("ant"),
            .symbol("fish"),
            .symbol("pawprint"),
            .symbol("leaf"),
            .symbol("heart")
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
            .indigo,
            .blue,
        ]

        // 配置一些默认颜色，方便后期与主题同步调整对应颜色而不是固定的颜色值
        case blue
        case brown
        case green
        case indigo
        case orange
        case pink
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
            case .green: return "green"
            case .indigo: return "indigo"
            case .orange: return "orange"
            case .pink: return "pink"
            case .red: return "red"
            case .yellow: return "yellow"
            case .custom(color: let color): return Self.customPrefix + color.hex
            }
        }

        var color: SwiftUI.Color {
            switch self {
            case .blue: return .appBlue
            case .brown: return .appBrown
            case .green: return .appGreen
            case .indigo: return .appIndigo
            case .orange: return .appOrange
            case .pink: return .appPink
            case .red: return .appRed
            case .yellow: return .appYellow
            case .custom(color: let color): return color
            }
        }
    }
}
