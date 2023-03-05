//
//  AssisChatApp.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import SwiftUI

@main
struct AssisChatApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
