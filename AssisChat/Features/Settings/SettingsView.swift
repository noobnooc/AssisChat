//
//  SettingsView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-06.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsFeature: SettingsFeature

    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            Section {
                ProBanner()
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            Section("SETTINGS_CHAT") {
                NavigationLink {
                    ChatSourceConfigView(successAlert: true, backWhenConfigured: false) { _ in

                    }
                    .navigationTitle("SETTINGS_CHAT_SOURCE")
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("SETTINGS_CHAT_SOURCE")

                            Text("Config the API Key for ChatGPT or Claude.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.top, 5)
                        }
                    } icon: {
                        Image(systemName: "globe.asia.australia")
                    }
                }

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
            }

            Section("Features") {
                SettingsFeatures()
            }

            Section("SETTINGS_THEME") {
                SettingsThemeContent()
            }

            Section("SETTINGS_ABOUT") {
                SettingsAboutContent()
            }

            CopyrightView(detailed: true)
                .listRowBackground(Color.clear)
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
        .inlineNavigationBar()
    }
}

struct SettingsFeatures: View {
    var body: some View {
        NavigationLink {
            ShareExtensionIntroduction()
        } label: {
            Label {
                Text("Share Extension")
            } icon: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.appGreen)
            }
        }

        NavigationLink {
            KeyboardExtensionIntroduction()
        } label: {
            Label {
                Text("Keyboard Extension")
            } icon: {
                Image(systemName: "keyboard")
                    .foregroundColor(.appBlue)
            }
        }
    }
}

struct SettingsThemeContent: View {
    @EnvironmentObject private var settingsFeature: SettingsFeature

    var body: some View {
        Picker(selection: $settingsFeature.selectedColorScheme) {
            ForEach(SettingsFeature.colorSchemes, id: \.self) { scheme in
                Text(scheme.localizedKey)
                    .tag(scheme)
            }
        } label: {
            Label {
                Text("SETTINGS_COLOR_SCHEME")
                    .foregroundColor(.primary)
                ProBadge()
            } icon: {
                Image(systemName: "die.face.5")
                    .foregroundColor(.appOrange)
            }
        }

        #if os(iOS)
        NavigationLink {
            TintSelector()
                .navigationTitle("SETTINGS_TINT")
        } label: {
            Label {
                Text("SETTINGS_TINT")
                    .foregroundColor(.primary)
                ProBadge()
            } icon: {
                Image(systemName: "paintbrush.pointed")
                    .foregroundColor(.appIndigo)
            }
        }
        #endif

        Picker(selection: $settingsFeature.selectedSymbolVariant) {
            ForEach(SettingsFeature.symbolVariants, id: \.self) { variant in
                Text(variant.localizedKey)
                    .tag(variant)
            }
        } label: {
            Label {
                Text("SETTINGS_SYMBOL_VARIANT")
                    .foregroundColor(.primary)
                ProBadge()
            } icon: {
                Image(systemName: "star")
                    .foregroundColor(.appYellow)
            }
        }

        Picker(selection: $settingsFeature.selectedFontSize) {
            ForEach(SettingsFeature.fontSizes, id: \.self) { fontSize in
                Text(verbatim: fontSize.localizedLabel)
                    .tag(fontSize)
            }
        } label: {
            Label {
                Text("Message Font Size", comment: "The label of the setting of message font size")
                    .foregroundColor(.primary)
                ProBadge()
            } icon: {
                Image(systemName: "textformat.size")
                    .foregroundColor(.appGreen)
            }
        }
    }
}

struct SettingsAboutContent: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            openURL(URL(string: String(localized: "https://twitter.com/AssisChatHQ", comment: "The link of the twitter account."))!)
        } label: {
            Label {
                Text(String("Twitter"))
                    .foregroundColor(.primary)
            } icon: {
                Image(systemName: "bird")
                    .foregroundColor(.appBlue)
            }
        }

        Button {
            openURL(URL(string: String(localized: "https://t.me/AssisChatHQ", comment: "The link of the Telegram group."))!)
        } label: {
            Label {
                Text(String("Telegram"))
                    .foregroundColor(.primary)
            } icon: {
                Image(systemName: "paperplane")
                    .foregroundColor(.appBlue)
            }
        }

        Button {
            openURL(URL(string: "mailto:app@nooc.ink")!)
        } label: {
            Label {
                Text("SETTINGS_FEEDBACK")
                    .foregroundColor(.primary)
            } icon: {
                Image(systemName: "envelope")
                    .foregroundColor(.appGreen)
            }
        }

        #if os(iOS)
        NavigationLink {
            AcknowledgmentView()
        } label: {
            Label {
                Text("SETTINGS_ACKNOWLEDGMENTS")
                    .foregroundColor(.primary)
            } icon: {
                Image(systemName: "heart")
                    .foregroundColor(.appRed)
            }
        }
        #endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
