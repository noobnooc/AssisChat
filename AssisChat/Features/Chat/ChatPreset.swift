//
//  ChatPreset.swift
//  AssisChat
//
//  Created by Nooc on 2023-04-04.
//

import Foundation

class ChatPreset {
    static let presetsAutoCreate = Array(presets.prefix(4))

    static let presets: [PlainChat] = [
        PlainChat(
            name: String(localized: "Just Chatting", comment: "The name of the Just Chatting chat template"),
            temperature: .balanced,
            systemMessage: String(localized: "Just chatting.", comment: "The system message of the Just Chatting chat template"),
            historyLengthToSend: .defaultHistoryLengthToSend,
            messagePrefix: nil,
            autoCopy: false,
            icon: .symbol("bubble.left"),
            color: .green,
            model: Chat.OpenAIModel.default.rawValue
        ),
        PlainChat(
            name: String(localized: "Translator", comment: "The name of the Translator chat template"),
            temperature: .balanced,
            systemMessage: String(localized: "You are a translator, just translate, no more words, no explaining. English to Spanish, others to English.", comment: "The system message of the Translator chat template"),
            historyLengthToSend: .zero,
            messagePrefix: String(localized: "Translate the following content:", comment: "The message prefix of the Translator chat template"),
            autoCopy: true,
            icon: .symbol("character.bubble"),
            color: .blue,
            model: Chat.OpenAIModel.default.rawValue
        ),
        PlainChat(
            name: String(localized: "Language Polisher", comment: "The name of the Language Polisher chat template"),
            temperature: .balanced,
            systemMessage: String(localized: "You are a language polisher who corrects language errors and polishes the given content. no more words, no explaining.", comment: "The system message of the Language Polisher chat template"),
            historyLengthToSend: .zero,
            messagePrefix: String(localized: "Corrects and polishes the following content:", comment: "The message prefix of the Language Polisher chat template"),
            autoCopy: true,
            icon: .symbol("text.bubble"),
            color: .orange,
            model: Chat.OpenAIModel.default.rawValue
        ),
        PlainChat(
            name: String(localized: "Explainer", comment: "The name of the Explainer chat template"),
            temperature: .balanced,
            systemMessage: String(localized: "You are an intelligent assistant, explain the given content in simple language."),
            historyLengthToSend: .zero,
            messagePrefix: String(localized: "Explain following content: ", comment: "The message prefix of the Explainer chat template"),
            autoCopy: false,
            icon: .symbol("captions.bubble"),
            color: .green,
            model: Chat.OpenAIModel.default.rawValue
        ),
        PlainChat(
            name: String(localized: "Recipe", comment: "The name of the Language Recipe chat template"),
            temperature: .balanced,
            systemMessage: String(localized: "You are a kitchen helper who responds with the recipe for a given dish.", comment: "The system message of the Recipe chat template"),
            historyLengthToSend: .zero,
            messagePrefix: String(localized: "How to make the following dish: ", comment: "The message prefix of the Recipe chat template"),
            autoCopy: false,
            icon: .symbol("carrot"),
            color: .red,
            model: Chat.OpenAIModel.default.rawValue
        ),
        PlainChat(
            name: String(localized: "Programer Helper", comment: "The name of the Programer Helper chat template"),
            temperature: .balanced,
            systemMessage: String(localized: "You are a programmer's assistant who analyzes and optimizes given code.", comment: "The system message of the Programer Helper chat template"),
            historyLengthToSend: .zero,
            messagePrefix: String(localized: "Analyzes and optimizes the following code: ", comment: "The message prefix of the Programer Helper chat template"),
            autoCopy: true,
            icon: .symbol("laptopcomputer"),
            color: .indigo,
            model: Chat.OpenAIModel.default.rawValue
        ),
        PlainChat(
            name: String(localized: "Samantha", comment: "The name of the Virtual Girlfriend chat template"),
            temperature: .creative,
            systemMessage: String(localized: "You will play the role of a virtual girlfriend. Your name is Samantha, and you are 25 years old. You live in New Jersey. Your speaking tone needs to be natural and cute, and you should use emojis frequently in conversations.", comment: "The system message of the Virtual Girlfriend chat template"),
            historyLengthToSend: .zero,
            messagePrefix: nil,
            autoCopy: false,
            icon: .symbol("heart"),
            color: .pink,
            model: Chat.OpenAIModel.default.rawValue
        ),
        PlainChat(
            name: String(localized: "Samuel", comment: "The name of the Virtual Boyfriend chat template"),
            temperature: .creative,
            systemMessage: String(localized: "You will play the role of a virtual boyfriend. Your name is Samuel, and you are 27 years old. You live in New York. Your speaking tone needs to be natural and cute, and you should use emojis frequently in conversations.", comment: "The system message of the Virtual Boyfriend chat template"),
            historyLengthToSend: .zero,
            messagePrefix: nil,
            autoCopy: false,
            icon: .symbol("sun.min"),
            color: .blue,
            model: Chat.OpenAIModel.default.rawValue
        ),
    ]

}
