//
//  ChattingFeature.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import Foundation
import SwiftUI

enum ChattingError: Error {
    case invalidConfig
    case sending(message: LocalizedStringKey)
    case validating(message: LocalizedStringKey)
}

protocol ChattingAdapter {
    func sendMessageWithStream(chat: Chat, receivingMessage: Message) async throws
    func sendMessage(message: Message) async throws -> [PlainMessage]
    func validateConfig() async throws
}

class ChattingFeature: ObservableObject {
    let essentialFeature: EssentialFeature
    let settingsFeature: SettingsFeature
    let chatFeature: ChatFeature
    let messageFeature: MessageFeature

    init(essentialFeature: EssentialFeature, settingsFeature: SettingsFeature, chatFeature: ChatFeature, messageFeature: MessageFeature) {
        self.essentialFeature = essentialFeature
        self.settingsFeature = settingsFeature
        self.chatFeature = chatFeature
        self.messageFeature = messageFeature
    }

    func send(plainMessage: PlainMessage) async {
        let message = messageFeature.createMessage(plainMessage)

        guard let message = message else { return }

        await send(message: message)
    }

    func sendWithStream(plainMessage: PlainMessage) async {
        await sendWithStream(plainMessage: plainMessage) {
            messageFeature.createReceivingMessage(for: plainMessage.chat)
        }
    }

    func sendWithStream(content: String, for chat: Chat, createReceivingMessage: () -> Message?) async {
        let processedContent = chat.preprocessContent(content: content)
        let plainMessage = PlainMessage(chat: chat, role: .user, content: content, processedContent: processedContent)

        await sendWithStream(plainMessage: plainMessage, createReceivingMessage: createReceivingMessage)
    }

    func sendWithStream(plainMessage: PlainMessage, createReceivingMessage: () -> Message?) async {
        _ = messageFeature.createMessage(plainMessage)

        let receivingMessage = createReceivingMessage()

        guard let receivingMessage = receivingMessage else { return }

        await sendWithStream(chat: plainMessage.chat, receivingMessage: receivingMessage)
    }

    func resendWithStream(receivingMessage: Message) async {
        guard let chat = receivingMessage.chat else { return }

        messageFeature.clearReceivingMessage(for: receivingMessage)
        await sendWithStream(chat: chat, receivingMessage: receivingMessage)
    }

    private func sendWithStream(chat: Chat, receivingMessage: Message) async {
        receivingMessage.markReceiving()

        do {
            guard let chattingAdapter = settingsFeature.chattingAdapter else { return }

            try await chattingAdapter.sendMessageWithStream(chat: chat, receivingMessage: receivingMessage)

            if chat.autoCopy {
                receivingMessage.copyToPasteboard()
            }
        } catch ChattingError.invalidConfig, GeneralError.badURL {
            essentialFeature.appendAlert(alert: ErrorAlert(message: "SETTINGS_CHAT_SOURCE_INCORRECT_HINT"))
        } catch ChattingError.sending(message: let message) {
            essentialFeature.appendAlert(alert: ErrorAlert(message: message))
        } catch {
            essentialFeature.appendAlert(alert: ErrorAlert(message: LocalizedStringKey(error.localizedDescription)))
        }

        receivingMessage.unmarkReceiving()
    }

    private func send(message: Message) async {
        guard let chat = message.chat else { return }

        do {
            guard let chattingAdapter = settingsFeature.chattingAdapter else { return }

            let plainMessages = try await chattingAdapter.sendMessage(message: message)

            let receivedMessages = messageFeature.createMessages(plainMessages)

            if let receivedMessage = receivedMessages.first, chat.autoCopy {
                receivedMessage.copyToPasteboard()
            }
        } catch ChattingError.invalidConfig, GeneralError.badURL {
            essentialFeature.appendAlert(alert: ErrorAlert(message: "SETTINGS_CHAT_SOURCE_INCORRECT_HINT"))
        } catch ChattingError.sending(message: let message) {
            essentialFeature.appendAlert(alert: ErrorAlert(message: message))
        } catch {
            essentialFeature.appendAlert(alert: ErrorAlert(message: LocalizedStringKey(error.localizedDescription)))
        }
    }
}
