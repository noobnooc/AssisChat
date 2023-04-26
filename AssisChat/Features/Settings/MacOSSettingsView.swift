//
//  MacOSSettingsView.swift
//  AssisChat
//
//  Created by Nooc on 2023-04-24.
//

import SwiftUI

struct MacOSSettingsView: View {
    @Environment(\.openURL) private var openURL
    
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
                ProBanner()
                    .frame(height: 100)
                    .padding()
                
                Spacer()
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
