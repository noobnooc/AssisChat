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
    @StateObject var proFeature: ProFeature
    @StateObject var settingsFeature: SettingsFeature
    let chatFeature: ChatFeature
    let messageFeature: MessageFeature
    let chattingFeature: ChattingFeature

    init() {
        SharedUserDefaults.migrateIfNeeded()

        let essentialFeature = EssentialFeature(persistenceController: persistenceController)
        let proFeature = ProFeature()
        let settingsFeature = SettingsFeature(essentialFeature: essentialFeature)

        _essentialFeature = StateObject(wrappedValue: essentialFeature)
        _proFeature = StateObject(wrappedValue: proFeature)
        _settingsFeature = StateObject(wrappedValue: settingsFeature)
        chatFeature = ChatFeature(essentialFeature: essentialFeature)
        messageFeature = MessageFeature(essentialFeature: essentialFeature)
        chattingFeature = ChattingFeature(
            essentialFeature: essentialFeature,
            settingsFeature: settingsFeature,
            chatFeature: chatFeature,
            messageFeature: messageFeature)

        #if os(iOS)
        UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBarAppearance()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
//            #if os(macOS)
//                .frame(minWidth: 800, minHeight: 500)
//            #endif

                .environment(\.managedObjectContext, persistenceController.container.viewContext)

                .environmentObject(essentialFeature)
                .environmentObject(proFeature)
                .environmentObject(settingsFeature)
                .environmentObject(chatFeature)
                .environmentObject(messageFeature)
                .environmentObject(chattingFeature)

                // Initiations
                .preferredColorScheme(settingsFeature.selectedColorScheme.systemColorScheme)
                .tint(settingsFeature.selectedTint?.color)
                .symbolVariant(settingsFeature.selectedSymbolVariant.system)

                // Error showing
                .alert(
                    essentialFeature.currentAlert?.title ?? "",
                    isPresented: Binding(get: {
                        return essentialFeature.currentAlert != nil
                    }, set: { value in
                        if !value {
                            essentialFeature.dismissCurrentAlert()
                        }
                    }), actions: {

                    }, message: {
                        Text(essentialFeature.currentAlert?.message ?? "")
                    })
        }

        #if os(macOS)
        Settings {
            MacOSSettingsView()
                .environmentObject(essentialFeature)
                .environmentObject(settingsFeature)
                .environmentObject(proFeature)

                // Initiations
                .preferredColorScheme(settingsFeature.selectedColorScheme.systemColorScheme)
                .tint(settingsFeature.selectedTint?.color)
                .symbolVariant(settingsFeature.selectedSymbolVariant.system)
        }
        #endif
    }
}
