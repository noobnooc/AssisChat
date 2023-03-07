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
    case sending(message: String)
}

protocol ChattingAdapter {
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

    func retry(chat: Chat) async {
        guard let lastMessage = chat.messages.last, lastMessage.role == .user else { return }

        await send(message: lastMessage)
    }

    private func send(message: Message) async {
        guard let chat = message.chat else { return }

        chat.markSending(sending: true)

        if chat.failed {
            chatFeature.unmarkFailed(for: chat)
        }

        do {
            guard let chattingAdapter = settingsFeature.chattingAdapter else { return }

            let plainMessages = try await chattingAdapter.sendMessage(message: message)

            _ = messageFeature.createMessages(plainMessages)
        } catch ChattingError.invalidConfig {
            chatFeature.markFailed(for: chat)
            essentialFeature.appendAlert(alert: ErrorAlert(message: "Please config the chat source."))
        } catch ChattingError.sending(message: let message) {
            chatFeature.markFailed(for: chat)
            essentialFeature.appendAlert(alert: ErrorAlert(message: LocalizedStringKey(message)))
        } catch GeneralError.badURL {
            chatFeature.markFailed(for: chat)
            essentialFeature.appendAlert(alert: ErrorAlert(message: "Please config the URL correctly."))
        } catch {
            chatFeature.markFailed(for: chat)
            essentialFeature.appendAlert(alert: ErrorAlert(message: LocalizedStringKey(error.localizedDescription)))
        }

        chat.markSending(sending: false)
    }
}
