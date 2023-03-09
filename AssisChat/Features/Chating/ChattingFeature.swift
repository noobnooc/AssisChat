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
}

protocol ChattingAdapter {
    func sendMessageWithStream(message: Message, receivingMessage: Message) async throws
    func sendMessage(message: Message) async throws -> [PlainMessage]
    func validateConfig() async -> Bool
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
        let message = messageFeature.createMessage(plainMessage)
        let receivingMessage = messageFeature.createReceivingMessage(for: plainMessage.chat)

        guard let message = message, let receivingMessage = receivingMessage else { return }

        await sendWithStream(message: message, receivingMessage: receivingMessage)
    }

    func retry(chat: Chat) async {
        guard let lastMessage = chat.messages.last, lastMessage.role == .user else { return }

        await send(message: lastMessage)
    }

    private func sendWithStream(message: Message, receivingMessage: Message) async {
        guard let chat = message.chat else { return }

        receivingMessage.markReceiving()

        do {
            guard let chattingAdapter = settingsFeature.chattingAdapter else { return }

            try await chattingAdapter.sendMessageWithStream(message: message, receivingMessage: receivingMessage)

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
