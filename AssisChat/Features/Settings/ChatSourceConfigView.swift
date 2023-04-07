//
//  ChatSourceConfigView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-06.
//

import SwiftUI

struct ChatSourceConfigView: View {
    @EnvironmentObject private var settingsFeature: SettingsFeature

    let successAlert: Bool
    let backWhenConfigured: Bool
    let onConfigured: (() -> Void)?

    var body: some View {
        Content(
            openAIAPIKey: settingsFeature.configuredOpenAIAPIKey ?? "",
            openAIDomain: settingsFeature.configuredOpenAIDomain ?? "",
            successAlert: successAlert,
            backWhenConfigured: backWhenConfigured,
            onConfigured: onConfigured
        )
    }
}

private struct Content: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var essentialFeature: EssentialFeature
    @EnvironmentObject private var settingsFeature: SettingsFeature

    @State var openAIAPIKey: String
    @State var openAIDomain: String

    @State private var validating = false

    let successAlert: Bool
    let backWhenConfigured: Bool
    let onConfigured: (() -> Void)?

    var body: some View {
        List {
            Section {
                SecureField(String("sk-XXXXXXX"), text: $openAIAPIKey)
                    .disableAutocorrection(true)
            } header: {
                Text("SETTINGS_CHAT_SOURCE_OPENAI_KEY")
            } footer: {
                Text("SETTINGS_CHAT_SOURCE_OPENAI_KEY_HINT")
            }

            Section {
                TextField(String("api.openai.com"), text: $openAIDomain)
                    .disableAutocorrection(true)
            } header: {
                Text("SETTINGS_CHAT_SOURCE_OPENAI_DOMAIN")
            } footer: {
                Text("SETTINGS_CHAT_SOURCE_OPENAI_DOMAIN_HINT")
            }

            Section {
                Button {
                    validateAndSave()
                } label: {
                    HStack {
                        if validating {
                            ProgressView()
                        }

                        Text("SETTINGS_CHAT_SOURCE_VALIDATE_AND_SAVE")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.primary)
                    .colorScheme(.dark)
                }
                .disabled(validating)
                .listRowInsets(EdgeInsets())
            } footer: {
                Text("The OpenAI API services are provided by OpenAI company, and the rights for data usage and fee collection are reserved by OpenAI company. You can find more information about data usage and fee collection at https://platform.openai.com.")
            }
        }
    }

    func validateAndSave() -> Void {
        Task {
            if openAIAPIKey.isEmpty {
                essentialFeature.appendAlert(alert: ErrorAlert(message: "SETTINGS_CHAT_SOURCE_NO_API_KEY"))
                return
            }

            let domain = openAIDomain.isEmpty ? nil : openAIDomain

            do {
                validating = true

                try await settingsFeature.validateAndConfigOpenAI(apiKey: openAIAPIKey, for: domain)

                if successAlert {
                    essentialFeature.appendAlert(alert: GeneralAlert(title: "SUCCESS", message: "SETTINGS_CHAT_SOURCE_VALIDATE_AND_SAVE_SUCCESS"))
                }

                onConfigured?()

                if backWhenConfigured {
                    dismiss()
                }
            } catch ChattingError.validating(message: let message) {
                essentialFeature.appendAlert(alert: ErrorAlert(message: message))
            } catch {
                essentialFeature.appendAlert(alert: ErrorAlert(message: LocalizedStringKey(error.localizedDescription)))
            }

            validating = false
        }
    }
}

struct ChatSourceConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ChatSourceConfigView(successAlert: false, backWhenConfigured: false) {

        }
    }
}
