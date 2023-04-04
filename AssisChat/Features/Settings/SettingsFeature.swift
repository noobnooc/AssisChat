//
//  SettingsFeature.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-06.
//

import Foundation
import SwiftUI

class SettingsFeature: ObservableObject {
    @AppStorage(SharedUserDefaults.colorScheme, store: SharedUserDefaults.shared) var selectedColorScheme: ColorScheme = .automatic
    @AppStorage(SharedUserDefaults.tint, store: SharedUserDefaults.shared) private(set) var selectedTint: Tint?
    @AppStorage(SharedUserDefaults.symbolVariant, store: SharedUserDefaults.shared) var selectedSymbolVariant: SymbolVariant = .fill
    @AppStorage(SharedUserDefaults.fontSize, store: SharedUserDefaults.shared) var selectedFontSize: FontSize = .normal
    @AppStorage(SharedUserDefaults.openAIDomain, store: SharedUserDefaults.shared) private(set) var configuredOpenAIDomain: String?
    @AppStorage(SharedUserDefaults.openAIAPIKey, store: SharedUserDefaults.shared) private(set) var configuredOpenAIAPIKey: String?
    @AppStorage(SharedUserDefaults.iCloudSync, store: SharedUserDefaults.shared) var iCloudSync = false {
        didSet {
            essentialFeature.setCloudSync(sync: iCloudSync)
        }
    }

    let essentialFeature: EssentialFeature

    @Published private(set) var chattingAdapter: ChattingAdapter?

    var adapterReady: Bool {
        return chattingAdapter != nil
    }

    init(essentialFeature: EssentialFeature) {
        self.essentialFeature = essentialFeature

        initiateAdapter()
    }

    func adjustColorScheme(_ colorScheme: ColorScheme) {
        selectedColorScheme = colorScheme
    }

    func adjustTint(_ tint: Tint?) {
        selectedTint = tint
    }

    func adjustSymbolVariant(_ variant: SymbolVariant) {
        selectedSymbolVariant = variant
    }

    func initiateAdapter() {
        guard let apiKey = configuredOpenAIAPIKey, !apiKey.isEmpty else {
            return
        }

        chattingAdapter = ChatGPTAdapter(essentialFeature: essentialFeature, config: .init(domain: configuredOpenAIDomain, apiKey: apiKey))
    }

    func validateAndConfigOpenAI(apiKey: String, for domain: String?) async throws {
        let adapter = ChatGPTAdapter(essentialFeature: essentialFeature, config: .init(domain: domain, apiKey: apiKey))

        try await adapter.validateConfig()

        chattingAdapter = adapter
        configuredOpenAIAPIKey = apiKey
        configuredOpenAIDomain = domain
    }
}

extension SettingsFeature {
    static let colorSchemes: [ColorScheme] = [
        .automatic,
        .light,
        .dark
    ]

    static let tints: [Tint] = [
        .green,
        .yellow,
        .orange,
        .brown,
        .red,
        .pink,
        .indigo,
        .blue,
    ]

    static let symbolVariants: [SymbolVariant] = [
        .fill,
        .outline,
    ]

    static let fontSizes: [FontSize] = [
        .large,
        .normal,
        .small,
    ]

    enum ColorScheme: String, Hashable {
        case automatic = "automatic", light = "light", dark = "dark"

        var systemColorScheme: SwiftUI.ColorScheme? {
            switch self {
            case .automatic: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }

        var localizedKey: LocalizedStringKey {
            switch self {
            case .automatic: return LocalizedStringKey("SETTINGS_COLOR_SCHEME_AUTOMATIC")
            case .light: return LocalizedStringKey("SETTINGS_COLOR_SCHEME_LIGHT")
            case .dark: return LocalizedStringKey("SETTINGS_COLOR_SCHEME_DARK")
            }
        }
    }

    enum Tint: String, Hashable {
        case green = "green"
        case yellow = "yellow"
        case orange = "orange"
        case brown = "brown"
        case red = "red"
        case pink = "pink"
        case indigo = "indigo"
        case blue = "blue"

        var color: Color {
            switch self {
            case .indigo: return .appIndigo
            case .blue: return .appBlue
            case .green: return .appGreen
            case .yellow: return .appYellow
            case .orange: return .appOrange
            case .brown: return .appBrown
            case .red: return .appRed
            case .pink: return .appPink
            }
        }
    }

    enum SymbolVariant: String, Hashable {
        case fill = "fill"
        case outline = "outline"

        var system: SymbolVariants {
            switch self {
            case .fill: return .fill
            case .outline: return .none
            }
        }

        var localizedKey: LocalizedStringKey {
            switch self {
            case .fill: return LocalizedStringKey("SETTINGS_SYMBOL_VARIANT_FILL")
            case .outline: return LocalizedStringKey("SETTINGS_SYMBOL_VARIANT_OUTLINE")
            }
        }
    }

    enum FontSize: String, Hashable {
        case large = "large"
        case normal = "normal"
        case small = "small"

        var size: Int {
            switch self {
            case .large: return 20
            case .normal: return 17
            case .small: return 14
            }
        }

        var localizedLabel: String {
            switch self {
            case .large: return String(localized: "Large", comment: "The large size label of font size setting")
            case .normal: return String(localized: "Normal", comment: "The normal size label of font size setting")
            case .small: return String(localized: "Small", comment: "The small size label of font size setting")
            }
        }
    }
}
