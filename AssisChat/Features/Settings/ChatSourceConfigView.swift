//
//  ChatSourceConfigView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-06.
//

import SwiftUI

struct ChatSourceConfigView: View {
    private enum Source {
        case chatGPT
        case claude
    }

    @EnvironmentObject private var settingsFeature: SettingsFeature

    let successAlert: Bool
    let backWhenConfigured: Bool
    let onConfigured: ((_: ChattingAdapter) -> Void)?

    @State private var selectedSource: Source = .chatGPT

    var body: some View {
        VStack(spacing: 0) {
            Picker(String("Selected Tab"), selection: $selectedSource) {
                Text("ChatGPT")
                    .tag(Source.chatGPT)

                Text("Claude")
                    .tag(Source.claude)
            }
            .pickerStyle(.segmented)
            .padding()

            TabView(selection: $selectedSource) {
                OpenAIContent(
                    openAIAPIKey: settingsFeature.configuredOpenAIAPIKey ?? "",
                    openAIDomain: settingsFeature.configuredOpenAIDomain ?? "",
                    successAlert: successAlert,
                    backWhenConfigured: backWhenConfigured,
                    onConfigured: onConfigured
                )
                .tag(Source.chatGPT)
                
                AnthropicContent(
                    apiKey: settingsFeature.configuredAnthropicAPIKey ?? "",
                    domain: settingsFeature.configuredAnthropicDomain ?? "",
                    successAlert: successAlert,
                    backWhenConfigured: backWhenConfigured,
                    onConfigured: onConfigured
                )
                .tag(Source.claude)
            }
            .tabViewStyle(.page)
            .ignoresSafeArea()
        }
        .background(Color.groupedBackground)
    }
}

private struct OpenAIContent: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var essentialFeature: EssentialFeature
    @EnvironmentObject private var settingsFeature: SettingsFeature

    @State var openAIAPIKey: String
    @State var openAIDomain: String

    @State private var validating = false

    let successAlert: Bool
    let backWhenConfigured: Bool
    let onConfigured: ((_: ChattingAdapter) -> Void)?

    var body: some View {
        List {
            Section {
                VStack {
                    Image("chatgpt")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

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

            CopyrightView()
                .listRowBackground(Color.clear)
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

                let adapter = try await settingsFeature.validateAndConfigOpenAI(apiKey: openAIAPIKey, for: domain)

                if successAlert {
                    essentialFeature.appendAlert(alert: GeneralAlert(title: "SUCCESS", message: "SETTINGS_CHAT_SOURCE_VALIDATE_AND_SAVE_SUCCESS"))
                }

                onConfigured?(adapter)

                if backWhenConfigured {
                    dismiss()
                }
            } catch ChattingError.validating {
                essentialFeature.appendAlert(alert: ErrorAlert(message: LocalizedStringKey("Failed to validate the API Key.")))
            } catch {
                essentialFeature.appendAlert(alert: ErrorAlert(message: LocalizedStringKey(error.localizedDescription)))
            }

            validating = false
        }
    }
}

private struct AnthropicContent: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var essentialFeature: EssentialFeature
    @EnvironmentObject private var settingsFeature: SettingsFeature

    @State var apiKey: String
    @State var domain: String

    @State private var validating = false

    let successAlert: Bool
    let backWhenConfigured: Bool
    let onConfigured: ((_: ChattingAdapter) -> Void)?

    var body: some View {
        List {
            Section {
                VStack {
                    Image("anthropic")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            Section {
                SecureField(String("sk-ant-XXXXXXX"), text: $apiKey)
                    .disableAutocorrection(true)
            } header: {
                Text("Claude API Key")
            } footer: {
                Text("Create a Claude API Key from https://console.anthropic.com/account/keys")
            }

            Section {
                TextField(String("api.anthropic.com"), text: $domain)
                    .disableAutocorrection(true)
            } header: {
                Text("Claude API domain (optional)")
            } footer: {
                Text("Use proxy domain. We recommend leaving it blank to use the default value. Please use a domain that you completely trust, otherwise your API key will be leaked.")
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
                Text("The Anthropic API and Claude services are provided by Anthropic company, and the rights for data usage and fee collection are reserved by Anthropic company. You can find more information about data usage and fee collection at https://www.anthropic.com.")
            }

            CopyrightView()
                .listRowBackground(Color.clear)
        }
    }

    func validateAndSave() -> Void {
        Task {
            if apiKey.isEmpty {
                essentialFeature.appendAlert(alert: ErrorAlert(message: "SETTINGS_CHAT_SOURCE_NO_API_KEY"))
                return
            }

            let domain = domain.isEmpty ? nil : domain

            do {
                validating = true

                let adapter = try await settingsFeature.validateAndConfigAnthropic(apiKey: apiKey, for: domain)

                if successAlert {
                    essentialFeature.appendAlert(alert: GeneralAlert(title: "SUCCESS", message: "SETTINGS_CHAT_SOURCE_VALIDATE_AND_SAVE_SUCCESS"))
                }

                onConfigured?(adapter)

                if backWhenConfigured {
                    dismiss()
                }
            } catch ChattingError.validating {
                essentialFeature.appendAlert(alert: ErrorAlert(message: LocalizedStringKey("Failed to validate the API Key.")))
            } catch {
                essentialFeature.appendAlert(alert: ErrorAlert(message: LocalizedStringKey(error.localizedDescription)))
            }

            validating = false
        }
    }
}

struct ChatSourceConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ChatSourceConfigView(successAlert: false, backWhenConfigured: false) { _ in

        }
    }
}
