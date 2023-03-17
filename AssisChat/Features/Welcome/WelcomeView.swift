//
//  WelcomeView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-06.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var settingsFeature: SettingsFeature

    var body: some View {
        Content(openAIAPIKey: settingsFeature.configuredOpenAIAPIKey ?? "", openAIDomain: settingsFeature.configuredOpenAIDomain ?? "")
    }
}

private struct Content: View {
    @EnvironmentObject private var essentialFeature: EssentialFeature
    @EnvironmentObject private var settingsFeature: SettingsFeature
    @EnvironmentObject private var chatFeature: ChatFeature

    @State var openAIAPIKey: String
    @State var openAIDomain: String
    @State private var validating = false
    @State private var errorMessage: LocalizedStringKey?

    var body: some View {
        Form {
            Section {
                VStack {
                    Image("Icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .cornerRadius(20)
                    Text("AssisChat")
                        .padding(.top)
                    Text("APP_SLOGAN")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)

            Section {
                Text("SETTINGS_CHAT_SOURCE_OPENAI_SUMMARY")
                    .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)
#if os(macOS)
            .padding(.top)
#endif

            Section {
#if os(iOS)
                TextField("sk-XXXXXXX", text: $openAIAPIKey)
#else
                TextField("", text: $openAIAPIKey)
                    .textFieldStyle(.roundedBorder)
#endif
            } header: {
                Text("SETTINGS_CHAT_SOURCE_OPENAI_KEY")
#if os(macOS)
                    .padding(.top)
#endif

            } footer: {
                Text("SETTINGS_CHAT_SOURCE_OPENAI_KEY_HINT")
            }
            Section {
#if os(iOS)
                TextField("api.openai.com", text: $openAIDomain)
#else
                TextField("", text: $openAIDomain)
                    .textFieldStyle(.roundedBorder)
#endif
            } header: {
                Text("SETTINGS_CHAT_SOURCE_OPENAI_DOMAIN")
#if os(macOS)
                    .padding(.top)
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
                            ProgressView()
#if os(macOS)
                                .frame(width: 12, height: 12)
#endif
                        }

                        Text("SETTINGS_CHAT_SOURCE_VALIDATE_AND_SAVE")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
#if os(iOS)
                    .background(Color.accentColor)
                    .foregroundColor(.primary)
                    .colorScheme(.dark)
#endif
                }
                .disabled(validating || openAIAPIKey.isEmpty)
                .listRowInsets(EdgeInsets())
            }
#if os(macOS)
            .padding(.top)
#endif
        }
        .alert("ERROR", isPresented: Binding(get: {
            errorMessage != nil
        }, set: { _ in
            errorMessage = nil
        }), actions: {

        }, message: {
            Text(errorMessage ?? "Unknown error")
        })
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

                chatFeature.createAllPresets()
            } catch ChattingError.validating(message: let message) {
                errorMessage = message
            } catch {
                errorMessage = LocalizedStringKey(error.localizedDescription)
            }

            validating = false
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
