//
//  SymbolVariantSelector.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-17.
//

import SwiftUI

struct SymbolVariantSelector: View {
    var body: some View {
        List {
            Section("SETTINGS_SYMBOL_VARIANT") {
                Selector()
            }
        }
    }
}

private struct Selector: View {
    @EnvironmentObject private var settingsFeature: SettingsFeature

    var body: some View {
        ForEach(SettingsFeature.symbolVariants, id: \.self) { symbolVariant in
            Label {
                Text(symbolVariant.localizedKey)
            } icon: {
                if symbolVariant == settingsFeature.selectedSymbolVariant {
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
                settingsFeature.adjustSymbolVariant(symbolVariant)
                Haptics.veryLight()
            }
        }
    }
}


struct SymbolVariantSelector_Previews: PreviewProvider {
    static var previews: some View {
        SymbolVariantSelector()
    }
}
