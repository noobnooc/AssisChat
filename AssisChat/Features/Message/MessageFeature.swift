//
//  MessageFeature.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import Foundation

struct PlainMessage {
    let chat: Chat
    let role: Message.Role
    let content: String

    var available: Bool {
        content.count > 0
    }
}

class MessageFeature: ObservableObject {
    let essentialFeature: EssentialFeature

    init(essentialFeature: EssentialFeature) {
        self.essentialFeature = essentialFeature
    }
}


// MARK: - Data
extension MessageFeature {
    func createMessage(_ plainMessage: PlainMessage) -> Message? {
        let messages = createMessages([plainMessage])

        return messages.first
    }

    func createMessages(_ plainMessages: [PlainMessage]) -> [Message] {
        guard plainMessages.allSatisfy({ message in
            message.available
        }) else {
            return []
        }

        var messages: [Message] = []

        for plainMessage in plainMessages {
            let message = Message(context: essentialFeature.context)

            message.rChat = plainMessage.chat
            message.rawRole = plainMessage.role.rawValue
            message.rawContent = plainMessage.content

            messages.append(message)
        }

        essentialFeature.persistData()

        return messages
    }

    func updateMessage(_ plainMessage: PlainMessage, for message: Message) {
        guard plainMessage.available else { return }

        message.rawRole = plainMessage.role.rawValue
        message.rawContent = plainMessage.content

        essentialFeature.persistData()
    }

    func deleteMessages(_ messages: [Message]) {
        messages.forEach(essentialFeature.context.delete)

        essentialFeature.persistData()
    }
}
