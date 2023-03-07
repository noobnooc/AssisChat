//
//  ColorSchemeSelector.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-06.
//

import SwiftUI

struct ColorSchemeSelector: View {
    var body: some View {
        List {
            Section("SETTINGS_COLOR_SCHEME") {
                Selector()
            }
        }
    }
}

private struct Selector: View {
    @EnvironmentObject private var settingsFeature: SettingsFeature

    var body: some View {
        ForEach(SettingsFeature.colorSchemes, id: \.self) { colorScheme in
            Label {
                Text(colorScheme.localizedKey)
            } icon: {
                if colorScheme == settingsFeature.selectedColorScheme {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                } else {
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 2)
                        .frame(width: 20, height: 20)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            // To ensure the whole row clickable
            .contentShape(Rectangle())
            .onTapGesture {
                settingsFeature.adjustColorScheme(colorScheme)
                Haptics.veryLight()
            }
        }
    }
}

struct ColorSchemeSelector_Previews: PreviewProvider {
    static var previews: some View {
        ColorSchemeSelector()
    }
}
