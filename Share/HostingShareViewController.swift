//
//  ShareViewController.swift
//  Share
//
//  Created by Nooc on 2023-03-31.
//

import UIKit
import SwiftUI
import Social

class HostingShareViewController: SLComposeServiceViewController {
    private let persistenceController = PersistenceController.shared
    private let essentialFeature: EssentialFeature
    private let settingsFeature: SettingsFeature
    private let chatFeature: ChatFeature
    private let messageFeature: MessageFeature
    private let chattingFeature: ChattingFeature

    private var sharedText: String = ""

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        SharedUserDefaults.migrateIfNeeded()

        essentialFeature = EssentialFeature(persistenceController: persistenceController)
        settingsFeature = SettingsFeature(essentialFeature: essentialFeature)
        chatFeature = ChatFeature(essentialFeature: essentialFeature)
        messageFeature = MessageFeature(essentialFeature: essentialFeature)
        chattingFeature = ChattingFeature(essentialFeature: essentialFeature, settingsFeature: settingsFeature, chatFeature: chatFeature, messageFeature: messageFeature)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
           let itemProvider = extensionItem.attachments?.first as? NSItemProvider,
           itemProvider.hasItemConformingToTypeIdentifier("public.text")
            || itemProvider.hasItemConformingToTypeIdentifier("public.url") {

            if itemProvider.hasItemConformingToTypeIdentifier("public.text") {
                itemProvider.loadItem(forTypeIdentifier: "public.text", options: nil) { [weak self] (text, error) in
                    if let sharedText = text as? String {
                        DispatchQueue.main.async {
                            self?.sharedText = sharedText
                            self?.presentShareView()
                        }
                    }
                }
            } else if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { [weak self] (url, error) in
                    if let sharedText = (url as? URL)?.absoluteString {
                        DispatchQueue.main.async {
                            self?.sharedText = sharedText
                            self?.presentShareView()
                        }
                    }
                }
            }

        }
    }

    private func presentShareView() {
        let shareView = ShareView(sharedText: sharedText, complete: { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: [])
        }, cancel: { [weak self] in
            self?.cancel()
        })

        let shareViewController = ShareViewController(
            rootView:
                shareView
                .environment(\.managedObjectContext, persistenceController.container.viewContext)

                .environmentObject(essentialFeature)
                .environmentObject(settingsFeature)
                .environmentObject(chatFeature)
                .environmentObject(messageFeature)
                .environmentObject(chattingFeature)

                // Initiations
                .preferredColorScheme(settingsFeature.selectedColorScheme.systemColorScheme)
                .tint(settingsFeature.selectedTint?.color)
                .symbolVariant(settingsFeature.selectedSymbolVariant.system)
        )

        self.view.addSubview(shareViewController.view)
    }
}
