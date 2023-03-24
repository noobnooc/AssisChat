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
    let content: String?
    let processedContent: String?

    var available: Bool {
        content != nil && content!.count > 0
    }

    static func from(message: Message) -> PlainMessage? {
        guard let chat = message.chat else { return nil }

        return PlainMessage(chat: chat, role: message.role, content: message.content ?? "", processedContent: message.processedContent)
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

    func createReceivingMessage(for chat: Chat) -> Message? {
        let plainMessage = PlainMessage(chat: chat, role: .assistant, content: nil, processedContent: nil)

        return createMessages([plainMessage], receiving: true).first
    }

    func updateMessageFailedReason(for message: Message, reason: Message.FailedReason?) {
        message.rawFailedReason = reason?.rawValue

        essentialFeature.persistData()
    }

    func createMessages(_ plainMessages: [PlainMessage], receiving: Bool = false) -> [Message] {
        guard receiving || plainMessages.allSatisfy({ message in
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
            message.rawProcessedContent = plainMessage.processedContent

            if receiving {
                message.tReceiving = true
            }

            messages.append(message)
        }

        essentialFeature.persistData()

        return messages
    }

    func updateMessage(_ plainMessage: PlainMessage, for message: Message) {
        guard plainMessage.available else { return }

        message.rawRole = plainMessage.role.rawValue
        message.rawContent = plainMessage.content
        message.rawProcessedContent = plainMessage.processedContent

        essentialFeature.persistData()
    }

    func deleteMessages(_ messages: [Message]) {
        messages.forEach(essentialFeature.context.delete)

        essentialFeature.persistData()
    }

    /// Clear data for message resending: such as empty content, clear failed reason
    func clearReceivingMessage(for message: Message) {
        message.rawContent = nil
        message.failedReason = nil

        essentialFeature.persistData()
    }
}
