//
//  MacOSSettingsView.swift
//  AssisChat
//
//  Created by Nooc on 2023-04-24.
//

import SwiftUI

struct MacOSSettingsView: View {
    @Environment(\.openURL) private var openURL

    @EnvironmentObject private var settingsFeature: SettingsFeature

#if os(macOS)
    static func open() {
        if #available(macOS 13, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
#endif

    var body: some View {
        TabView {
            VStack(alignment: .leading) {
                Toggle(isOn: $settingsFeature.iCloudSync) {
                    Label {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("iCloud Sync", comment: "iCloud Sync toggle label in settings")
                                .foregroundColor(.primary)

                            Text("Switching iCloud sync will take effect after restarting the app.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.top, 5)
                        }
                        ProBadge()
                    } icon: {
                        Image(systemName: "icloud")
                            .foregroundColor(.appBlue)
                    }
                }
                .padding()
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .tabItem {
                Label("General", systemImage: "gearshape")
            }

            VStack {
                ChatSourceConfigView(successAlert: true, backWhenConfigured: false, onConfigured: nil)
                Spacer()
            }
            .tabItem {
                Label("Chat Source", systemImage: "bubble.left")
            }

            VStack {
                Form {
                    SettingsThemeContent()
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .frame(alignment: .top)
            .padding()
            .tabItem {
                Label("Appearance", systemImage: "paintpalette")
            }


            VStack {
                ScrollView {
                    ProBanner()
                        .frame(height: 100)
                        .padding()

                    VStack {
                        ProFeatureList()
                    }

                    Spacer()
                }
            }
            .tabItem {
                Label("Coffee Plan", systemImage: "cup.and.saucer")
            }

            VStack {
                VStack {
                    SettingsAboutContent()
                }
                .padding()

                Spacer()
            }
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
        }
        .frame(minWidth: 500, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
    }
}

struct MacOSSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MacOSSettingsView()
    }
}
