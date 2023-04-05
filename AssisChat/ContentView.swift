//
//  ContentView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject private var settingsFeature: SettingsFeature

    var body: some View {
#if os(iOS)
        NavigationView {
            ChatsView()
                .navigationTitle("AssisChat")
                .inlineNavigationBar()
            SelectChatHintView()
        }
#else
        NavigationSplitView(sidebar: {
            ChatsView()
                .frame(width: 280)
                .navigationTitle("AssisChat")
                .navigationSplitViewColumnWidth(280)
        }, detail: {
            SelectChatHintView()
        })
#endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
