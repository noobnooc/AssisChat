//
//  SettingsView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-06.
//

import SwiftUI

struct SettingsView: View {
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
                    ChatSourceConfigView()
                        .navigationTitle("SETTINGS_CHAT_SOURCE")
                } label: {
                    Label("SETTINGS_CHAT_SOURCE", systemImage: "globe.asia.australia")
                }
            }

            Section("SETTINGS_THEME") {
                NavigationLink {
                    ColorSchemeSelector()
                        .navigationTitle("SETTINGS_COLOR_SCHEME")
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

                NavigationLink {
                    SymbolVariantSelector()
                        .navigationTitle("SETTINGS_SYMBOL_VARIANT")
                } label: {
                    Label {
                        Text("SETTINGS_SYMBOL_VARIANT")
                            .foregroundColor(.primary)
                        ProBadge()
                    } icon: {
                        Image(systemName: "star")
                            .foregroundColor(.appOrange)
                    }
                }
            }

            Section("SETTINGS_ABOUT") {
                Button {
                    openURL(URL(string: String(localized: "https://twitter.com/AssisChatHQ", comment: "The link of the twitter account."))!)
                } label: {
                    Label {
                        Text("Twitter")
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
                        Text("Telegram")
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
            }

            CopyrightView(detailed: true)
                .listRowBackground(Color.clear)
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
