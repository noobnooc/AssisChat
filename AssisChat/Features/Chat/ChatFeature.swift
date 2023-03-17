//
//  ChatFeature.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import Foundation
import Combine
import CoreData

struct PlainChat {
    let name: String
    let temperature: Chat.Temperature
    let systemMessage: String?
    let historyLengthToSend: Int16
    let messagePrefix: String?
    let autoCopy: Bool
    let icon: Chat.Icon
    let color: Chat.Color?
    let openAIModel: Chat.OpenAIModel

    var available: Bool {
        name.count > 0
    }
}

class ChatFeature: ObservableObject {
    let essentialFeature: EssentialFeature

    /**
    Uses to notify `orderedChats` change.
     */
    @Published var tick = 0

    @Published var chats: [Chat] = []

    var orderedChats: [Chat] {
        chats.sorted { c1, c2 in
            c1.orderTimestamp > c2.orderTimestamp
        }
    }

    var objectsSavedCancelable: AnyCancellable?

    init(essentialFeature: EssentialFeature) {
        self.essentialFeature = essentialFeature

        let fetchRequest = Chat.fetchRequest()
        let fetchedChats = try? essentialFeature.context.fetch(fetchRequest)

        self.chats = fetchedChats ?? []

        objectsSavedCancelable = NotificationCenter.default.publisher(for: NSManagedObjectContext.didSaveObjectsNotification, object: essentialFeature.context)
            .sink(receiveValue: { notification in
                self.checkObjectsDidChangeNotification(notification: notification)
            })
    }

    private func checkObjectsDidChangeNotification(notification: Notification) {
        for insertedObject in notification.insertedObjects ?? [] {
            if let insertedAccount = insertedObject as? Chat {
                chats.append(insertedAccount)
            }
        }

        if let deletedAccountIds = notification.deletedObjects?.compactMap({ ($0 as? Chat)?.objectID}), deletedAccountIds.count > 0 {
            let deletedAccountIdSet = Set(deletedAccountIds)

            chats.removeAll { account in
                deletedAccountIdSet.contains(account.objectID)
            }
        }

        tick += 1
    }
}


// MARK: - Data
extension ChatFeature {
    func createChat(_ plainChat: PlainChat) {
        guard plainChat.available else { return }

        let chat = Chat(context: essentialFeature.context)

        chat.rawName = plainChat.name
        chat.rawIcon = plainChat.icon.rawValue
        chat.color = plainChat.color
        chat.rawTemperature = plainChat.temperature.rawValue
        chat.rawSystemMessage = plainChat.systemMessage
        chat.rawHistoryLengthToSend = plainChat.historyLengthToSend
        chat.rawMessagePrefix = plainChat.messagePrefix
        chat.rawAutoCopy = plainChat.autoCopy
        chat.rawOpenAIModel = plainChat.openAIModel.rawValue

        essentialFeature.persistData()
    }

    func updateChat(_ plainChat: PlainChat, for chat: Chat) {
        guard plainChat.available else { return }

        chat.rawName = plainChat.name
        chat.rawIcon = plainChat.icon.rawValue
        chat.color = plainChat.color
        chat.rawTemperature = plainChat.temperature.rawValue
        chat.rawSystemMessage = plainChat.systemMessage
        chat.rawHistoryLengthToSend = plainChat.historyLengthToSend
        chat.rawMessagePrefix = plainChat.messagePrefix
        chat.rawAutoCopy = plainChat.autoCopy
        chat.rawOpenAIModel = plainChat.openAIModel.rawValue

        essentialFeature.persistData()
    }

    func clearMessages(for chat: Chat) {
        chat.rMessages = []

        essentialFeature.persistData()
    }

    func deleteChats(_ chats: [Chat]) {
        chats.forEach(essentialFeature.context.delete)

        essentialFeature.persistData()
    }
}


// MARK: - Templates
extension ChatFeature {
    func createAllPresets() {
        // Reversed for correct order
        for template in Self.presets.reversed() {
            createChat(template)
        }
    }

    static let presets: [PlainChat] = [
        PlainChat(
            name: String(localized: "Just Chatting", comment: "The name of the Just Chatting chat template"),
            temperature: .balanced,
            systemMessage: String(localized: "Just chatting.", comment: "The system message of the Just Chatting chat template"),
            historyLengthToSend: .defaultHistoryLengthToSend,
            messagePrefix: nil,
            autoCopy: false,
            icon: .symbol("bubble.left"),
            color: .green,
            openAIModel: .default
        ),
        PlainChat(
            name: String(localized: "Translator", comment: "The name of the Translator chat template"),
            temperature: .balanced,
            systemMessage: String(localized: "You are a translator who translates between English and Spanish.", comment: "The system message of the Translator chat template"),
            historyLengthToSend: .zero,
            messagePrefix: String(localized: "Translate the following content:", comment: "The message prefix of the Translator chat template"),
            autoCopy: true,
            icon: .symbol("character.bubble"),
            color: .blue,
            openAIModel: .default
        ),
        PlainChat(
            name: String(localized: "Language Polisher", comment: "The name of the Language Polisher chat template"),
            temperature: .balanced,
            systemMessage: String(localized: "You are a language polisher who corrects language errors and polishes the given content.", comment: "The system message of the Language Polisher chat template"),
            historyLengthToSend: .zero,
            messagePrefix: String(localized: "Corrects and polishes the following content:", comment: "The message prefix of the Language Polisher chat template"),
            autoCopy: true,
            icon: .symbol("text.bubble"),
            color: .orange,
            openAIModel: .default
        ),
        PlainChat(
            name: String(localized: "Recipe", comment: "The name of the Language Recipe chat template"),
            temperature: .balanced,
            systemMessage: String(localized: "You are a kitchen helper who responds with the recipe for a given dish.", comment: "The system message of the Recipe chat template"),
            historyLengthToSend: .zero,
            messagePrefix: String(localized: "How to make the following dish: ", comment: "The message prefix of the Recipe chat template"),
            autoCopy: false,
            icon: .symbol("carrot"),
            color: .red,
            openAIModel: .default
        ),
        PlainChat(
            name: String(localized: "Programer Helper", comment: "The name of the Programer Helper chat template"),
            temperature: .balanced,
            systemMessage: String(localized: "You are a programmer's assistant who analyzes and optimizes given code.", comment: "The system message of the Programer Helper chat template"),
            historyLengthToSend: .zero,
            messagePrefix: String(localized: "Analyzes and optimizes the following code: ", comment: "The message prefix of the Programer Helper chat template"),
            autoCopy: true,
            icon: .symbol("laptopcomputer"),
            color: .indigo,
            openAIModel: .default
        ),
    ]
}
