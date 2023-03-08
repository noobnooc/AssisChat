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
        NavigationView {
            ChatsView()
                .navigationTitle("AssisChat")
                .navigationBarTitleDisplayMode(.inline)

            SelectChatHintView()
        }

        // Welcome
        .sheet(isPresented: Binding(get: {
            !settingsFeature.adapterReady
        }, set: { _ in })) {
            WelcomeView()
                .interactiveDismissDisabled()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
