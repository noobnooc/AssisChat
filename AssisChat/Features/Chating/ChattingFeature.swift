//
//  ChattingFeature.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import Foundation
import SwiftUI
import SwiftSoup

enum ChattingError: Error {
    case invalidConfig
    case sending(message: LocalizedStringKey)
    case validating(message: LocalizedStringKey)
}

protocol ChattingAdapter {
    var priority: Int { get }
    var identifier: String { get }
    var defaultModel: String { get }
    var models: [String] { get }

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

    func sendWithStream(content: String, to chat: Chat) async -> Message? {
        let processedContent = await preprocessMessage(content: content, for: chat)

        let plainMessage = PlainMessage(chat: chat, role: .user, content: content, processedContent: processedContent)

        return await sendWithStream(plainMessage: plainMessage)
    }

    func sendWithStream(plainMessage: PlainMessage, waitingToComplete: Bool = false) async -> Message? {
        _ = messageFeature.createMessage(plainMessage)

        guard let receivingMessage = messageFeature.createReceivingMessage(for: plainMessage.chat) else {
            return nil
        }

        if waitingToComplete {
            await sendWithStream(chat: plainMessage.chat, receivingMessage: receivingMessage)
        } else {
            Task.detached {
                await self.sendWithStream(chat: plainMessage.chat, receivingMessage: receivingMessage)
            }
        }

        return receivingMessage
    }

    func resendWithStream(receivingMessage: Message) async {
        guard let chat = receivingMessage.chat else { return }

        messageFeature.clearReceivingMessage(for: receivingMessage)
        await sendWithStream(chat: chat, receivingMessage: receivingMessage)
    }

    private func sendWithStream(chat: Chat, receivingMessage: Message) async {
        receivingMessage.markReceiving()

        do {
            guard let model = chat.model, let adapter = settingsFeature.modelToAdapter[model] else { return }

            try await adapter.sendMessageWithStream(chat: chat, receivingMessage: receivingMessage)

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
            guard let chattingAdapter = settingsFeature.modelToAdapter[chat.rawModel ?? ""] else { return }

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

    private func preprocessMessage(content: String, for chat: Chat) async -> String {
        var processingContent = content

        if
            let url = URL(string: content),
            url.scheme?.lowercased() == "http" || url.scheme?.lowercased() == "https",
            url.host != nil {

            if let urlContent = await essentialFeature.getURLContent(url: url) {
                if
                    let doc = try? SwiftSoup.parse(urlContent),
                        let text = try? doc.text(trimAndNormaliseWhitespace: true) {
                    processingContent = text
                } else {
                    processingContent = urlContent
                }
            }
        }

        if let prefix = chat.messagePrefix {
            processingContent = prefix + "\n\n" + processingContent
        }

        return processingContent
    }
}
