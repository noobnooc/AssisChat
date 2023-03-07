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
    let messageFeature: MessageFeature

    init(essentialFeature: EssentialFeature, settingsFeature: SettingsFeature, messageFeature: MessageFeature) {
        self.essentialFeature = essentialFeature
        self.settingsFeature = settingsFeature
        self.messageFeature = messageFeature
    }

    func sendMessage(plainMessage: PlainMessage) async {
        do {
            guard let chattingAdapter = settingsFeature.chattingAdapter else { return }

            let message = messageFeature.createMessage(plainMessage)

            guard let message = message else { return }

            let plainMessages = try await chattingAdapter.sendMessage(message: message)

            _ = messageFeature.createMessages(plainMessages)
        } catch ChattingError.invalidConfig {
            essentialFeature.appendAlert(alert: ErrorAlert(message: "Please config the chat source."))
        } catch ChattingError.sending(message: let message) {
            essentialFeature.appendAlert(alert: ErrorAlert(message: LocalizedStringKey(message)))
        } catch GeneralError.badURL {
            essentialFeature.appendAlert(alert: ErrorAlert(message: "Please config the URL correctly."))
        } catch {
            essentialFeature.appendAlert(alert: ErrorAlert(message: LocalizedStringKey(error.localizedDescription)))
        }
    }
}
