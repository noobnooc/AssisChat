//
//  SettingsView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-06.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section {
                Text("AssisChat")
                    .font(.title)
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
                    Label("Color Scheme", systemImage: "die.face.5")
                }

                NavigationLink {
                    TintSelector()
                        .navigationTitle("Tint")
                } label: {
                    Label("Tint", systemImage: "paintbrush.pointed")
                }
            }

            Section("About") {
                Button {

                } label: {
                    Label("Share", systemImage: "arrowshape.turn.up.right")
                }

                NavigationLink {
                    Text("Feedback")
                } label: {
                    Label("Feedback", systemImage: "envelope")
                }

                NavigationLink {
                    Text("About")
                } label: {
                    Label("About", systemImage: "info.bubble")
                }

            }
        }
        .listStyle(.insetGrouped)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
