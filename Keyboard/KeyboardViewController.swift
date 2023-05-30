//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Nooc on 2023-05-06.
//

import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    private let persistenceController = PersistenceController.shared
    private let essentialFeature: EssentialFeature
    private let settingsFeature: SettingsFeature
    private let chatFeature: ChatFeature
    private let messageFeature: MessageFeature
    private let chattingFeature: ChattingFeature

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

    @IBOutlet var nextKeyboardButton: UIButton!

    private var keyboardViewModel: KeyboardViewModel?

    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = KeyboardViewModel { text in
            self.textDocumentProxy.insertText(text)
        } replace: { text in
            self.deleteInputText()
            self.textDocumentProxy.insertText(text)
        }

        keyboardViewModel = model

        let hostingController = UIHostingController(
            rootView: KeyboardView(viewController: self, model: model)
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
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        view.addSubview(hostingController.view)

        hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        hostingController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        hostingController.view.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .system)
        
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    override func viewWillLayoutSubviews() {
        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.

        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])

        guard let model = keyboardViewModel else { return }

        if let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty {
            model.selectedText = selectedText
        } else {
            model.selectedText = getFullText()
        }
    }

    private func getFullText() -> String {
        let precedingText = textDocumentProxy.documentContextBeforeInput ?? ""
        let followingText = textDocumentProxy.documentContextAfterInput ?? ""
        let selectedText = textDocumentProxy.selectedText ?? ""
        let fullText = "\(precedingText)\(selectedText)\(followingText)"

        return fullText
    }

    func deleteInputText() {
        textDocumentProxy.adjustTextPosition(byCharacterOffset: textDocumentProxy.documentContextAfterInput?.count ?? 0)

        while textDocumentProxy.hasText {
            textDocumentProxy.deleteBackward()
        }
    }
}
