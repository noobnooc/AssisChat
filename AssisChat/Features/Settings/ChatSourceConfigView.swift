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
            Picker(selection: $selectedSource) {
                Text("ChatGPT")
                    .tag(Source.chatGPT)

                Text("Claude")
                    .tag(Source.claude)
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 5)

            if selectedSource == .chatGPT {
                let view = OpenAIContent(
                    openAIAPIKey: settingsFeature.configuredOpenAIAPIKey ?? "",
                    openAIDomain: settingsFeature.configuredOpenAIDomain ?? "",
                    successAlert: successAlert,
                    backWhenConfigured: backWhenConfigured,
                    onConfigured: onConfigured
                )
                .ignoresSafeArea()
                .tag(Source.chatGPT)

                if #available(iOS 16, macOS 13, *) {
                    view.scrollDismissesKeyboard(.immediately)
                } else {
                    view
                }
            } else if selectedSource == .claude {
                let view = AnthropicContent(
                    apiKey: settingsFeature.configuredAnthropicAPIKey ?? "",
                    domain: settingsFeature.configuredAnthropicDomain ?? "",
                    successAlert: successAlert,
                    backWhenConfigured: backWhenConfigured,
                    onConfigured: onConfigured
                )
                .ignoresSafeArea()
                .tag(Source.claude)

                if #available(iOS 16, macOS 13, *) {
                    view.scrollDismissesKeyboard(.immediately)
                } else {
                    view
                }
            }
        }
#if os(iOS)
        .background(Color.groupedBackground)
#endif
    }
}

private struct OpenAIContent: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var settingsFeature: SettingsFeature

    @State var alertText: LocalizedStringKey? = nil
    @State var openAIAPIKey: String
    @State var openAIDomain: String

    @State private var validating = false

    let successAlert: Bool
    let backWhenConfigured: Bool
    let onConfigured: ((_: ChattingAdapter) -> Void)?

    var body: some View {
            Form {
#if os(iOS)
                Section {
                    VStack {
                        Image("chatgpt")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
#endif

                Section {
#if os(iOS)
                    SecureField(String("sk-XXXXXXX"), text: $openAIAPIKey)
                        .disableAutocorrection(true)
#else
                    SecureField("", text: $openAIAPIKey)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
#endif
                } header: {
                    Text("SETTINGS_CHAT_SOURCE_OPENAI_KEY")
                } footer: {
                    Text("SETTINGS_CHAT_SOURCE_OPENAI_KEY_HINT")
                }

                Section {
#if os(iOS)
                    TextField(String("api.openai.com"), text: $openAIDomain)
                        .disableAutocorrection(true)
#else
                    TextField("", text: $openAIDomain)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
#endif
                } header: {
                    Text("SETTINGS_CHAT_SOURCE_OPENAI_DOMAIN")
#if os(macOS)
                        .padding(.top, 20)
#endif
                } footer: {
                    Text("SETTINGS_CHAT_SOURCE_OPENAI_DOMAIN_HINT")
                }

                Section {
                    Button {
                        validateAndSave()
                    } label: {
                        HStack {
                            if validating {
                                UniformProgressView()
                            }

                            Text("SETTINGS_CHAT_SOURCE_VALIDATE_AND_SAVE")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
#if os(iOS)
                        .padding()
#else
                        .padding(5)
#endif
                        .background(Color.accentColor)
                        .foregroundColor(.primary)
                        .colorScheme(.dark)
                        .cornerRadius(10)
                    }
                    .disabled(validating)
                    .listRowInsets(EdgeInsets())
                    .buttonStyle(.plain)
                } footer: {
                    Text("The OpenAI API services are provided by OpenAI company, and the rights for data usage and fee collection are reserved by OpenAI company. You can find more information about data usage and fee collection at https://platform.openai.com.")
                }

                CopyrightView()
                    .listRowBackground(Color.clear)
            }
        #if os(macOS)
            .padding()
        #endif
            .alert(alertText ?? "", isPresented: Binding(get: {
                alertText != nil
            }, set: { _ in
                alertText = nil
            })) {

            }
    }

    func validateAndSave() -> Void {
        Task {
            if openAIAPIKey.isEmpty {
                alertText = "SETTINGS_CHAT_SOURCE_NO_API_KEY"
                return
            }

            let domain = openAIDomain.isEmpty ? nil : openAIDomain

            do {
                validating = true

                let adapter = try await settingsFeature.validateAndConfigOpenAI(apiKey: openAIAPIKey, for: domain)

                if successAlert {
                    alertText = "SETTINGS_CHAT_SOURCE_VALIDATE_AND_SAVE_SUCCESS"
                }

                onConfigured?(adapter)

                if backWhenConfigured {
                    dismiss()
                }
            } catch ChattingError.validating(let message) {
                alertText = message
            } catch {
                alertText = LocalizedStringKey(error.localizedDescription)
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
        Form {
#if os(iOS)
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
#endif

            Section {
#if os(iOS)
                SecureField(String("sk-ant-XXXXXXX"), text: $apiKey)
                    .disableAutocorrection(true)
#else
                SecureField("", text: $apiKey)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
#endif
            } header: {
                Text("Claude API Key")
            } footer: {
                Text("Create a Claude API Key from https://console.anthropic.com/account/keys")
            }

            Section {
#if os(iOS)
                TextField(String("api.anthropic.com"), text: $domain)
                    .disableAutocorrection(true)
#else
                TextField("", text: $domain)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
#endif
            } header: {
                Text("Claude API domain (optional)")
#if os(macOS)
                    .padding(.top, 20)
#endif
            } footer: {
                Text("Use proxy domain. We recommend leaving it blank to use the default value. Please use a domain that you completely trust, otherwise your API key will be leaked.")
            }

            Section {
                Button {
                    validateAndSave()
                } label: {
                    HStack {
                        if validating {
                            UniformProgressView()
                        }

                        Text("SETTINGS_CHAT_SOURCE_VALIDATE_AND_SAVE")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
#if os(iOS)
                    .padding()
#else
                    .padding(5)
#endif
                    .background(Color.accentColor)
                    .foregroundColor(.primary)
                    .colorScheme(.dark)
                    .cornerRadius(10)
                }
                .disabled(validating)
                .listRowInsets(EdgeInsets())
                .buttonStyle(.plain)
            } footer: {
                Text("The Anthropic API and Claude services are provided by Anthropic company, and the rights for data usage and fee collection are reserved by Anthropic company. You can find more information about data usage and fee collection at https://www.anthropic.com.")
            }

            CopyrightView()
                .listRowBackground(Color.clear)
        }
        #if os(macOS)
        .padding()
        #endif
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
            } catch ChattingError.validating(let message) {
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
        ChatSourceConfigView(successAlert: false, backWhenConfigured: false) { _ in

        }
    }
}
