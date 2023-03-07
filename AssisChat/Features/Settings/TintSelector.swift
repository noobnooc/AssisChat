//
//  TintSelector.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-06.
//

import SwiftUI

struct TintSelector: View {
    var body: some View {
        List {
            Section("SETTINGS_TINT") {
                Selector()
            }
        }
    }
}


private struct Selector: View {
    @EnvironmentObject var settingsFeature: SettingsFeature

    static let indicatorSize: CGFloat = 30

    private let gridLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        LazyVGrid(columns: gridLayout) {
            ForEach(SettingsFeature.tints, id: \.rawValue) { tint in
                tint.color
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(12)
                    .padding(10)
                    .overlay(alignment: .center) {
                        Color.white
                            .frame(width: Self.indicatorSize, height: Self.indicatorSize)
                            .cornerRadius(Self.indicatorSize)
                            .opacity(tint == settingsFeature.selectedTint ? 1 : 0)
                    }
                    .onTapGesture {
                        if settingsFeature.selectedTint == tint {
                            settingsFeature.adjustTint(nil)
                        } else {
                            settingsFeature.adjustTint(tint)
                        }

                        Haptics.veryLight()
                    }
            }
        }
    }
}

struct TintSelector_Previews: PreviewProvider {
    static var previews: some View {
        TintSelector()
    }
}
