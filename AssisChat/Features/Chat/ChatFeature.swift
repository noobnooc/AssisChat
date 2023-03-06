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
    let icon: Chat.Icon
    let color: Chat.Color?

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

        essentialFeature.persistData()
    }

    func updateChat(_ plainChat: PlainChat, for chat: Chat) {
        guard plainChat.available else { return }

        chat.rawName = plainChat.name
        chat.rawIcon = plainChat.icon.rawValue
        chat.color = plainChat.color
        chat.rawTemperature = plainChat.temperature.rawValue
        chat.rawSystemMessage = plainChat.systemMessage

        essentialFeature.persistData()
    }

    func deleteChats(_ chats: [Chat]) {
        chats.forEach(essentialFeature.context.delete)

        essentialFeature.persistData()
    }
}
