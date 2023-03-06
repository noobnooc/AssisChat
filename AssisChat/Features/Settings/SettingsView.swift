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
                VStack {
                    Image("Icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .cornerRadius(20)
                    Text("AssisChat")
                        .padding(.top)
                    Text("Assistant chatting.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)

            Section("Chat") {
                NavigationLink {
                    ChatSourceConfigView()
                        .navigationTitle("Chat Source")
                } label: {
                    Label("Source", systemImage: "globe.asia.australia")
                }
            }

            Section("Theme") {
                NavigationLink {
                    ColorSchemeSelector()
                        .navigationTitle("Color Scheme")
                } label: {
                    Label {
                        Text("Color Scheme")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "die.face.5")
                            .foregroundColor(.appOrange)
                    }
                }

                NavigationLink {
                    TintSelector()
                        .navigationTitle("Tint")
                } label: {
                    Label {
                        Text("Tint")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "paintbrush.pointed")
                            .foregroundColor(.appIndigo)
                    }
                }
            }

            Section("About") {
                Button {
                    openURL(URL(string: "https://twitter.com/noobnooc")!)
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
                    openURL(URL(string: "mailto:app@nooc.ink")!)
                } label: {
                    Label {
                        Text("Feedback")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "envelope")
                            .foregroundColor(.appRed)
                    }
                }
            }

            CopyrightView(detailed: true)
                .listRowBackground(Color.clear)
        }
        .listStyle(.insetGrouped)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
