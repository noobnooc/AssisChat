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

    @StateObject var essentialFeature: EssentialFeature
    @StateObject var settingsFeature: SettingsFeature
    let chatFeature: ChatFeature
    let messageFeature: MessageFeature
    let chattingFeature: ChattingFeature

    init() {
        let essentialFeature = EssentialFeature(context: persistenceController.container.viewContext)
        let settingsFeature = SettingsFeature(essentialFeature: essentialFeature)

        _essentialFeature = StateObject(wrappedValue: essentialFeature)
        _settingsFeature = StateObject(wrappedValue: settingsFeature)
        chatFeature = ChatFeature(essentialFeature: essentialFeature)
        messageFeature = MessageFeature(essentialFeature: essentialFeature)
        chattingFeature = ChattingFeature(essentialFeature: essentialFeature, settingsFeature: settingsFeature, messageFeature: messageFeature)

        UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)

                .environmentObject(essentialFeature)
                .environmentObject(settingsFeature)
                .environmentObject(chatFeature)
                .environmentObject(messageFeature)
                .environmentObject(chattingFeature)

                // Initiations
                .preferredColorScheme(settingsFeature.selectedColorScheme.systemColorScheme)
                .tint(settingsFeature.selectedTint?.color)
                .symbolVariant(.fill)

                // Error showing
                .alert(
                    essentialFeature.currentAlert?.title ?? "",
                    isPresented: Binding(get: {
                        essentialFeature.currentAlert != nil
                    }, set: { value in
                        if !value {
                            essentialFeature.dismissCurrentAlert()
                        }
                    }), actions: {

                    }, message: {
                        Text(essentialFeature.currentAlert?.message ?? "")
                    })
        }
    }
}
