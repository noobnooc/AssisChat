//
//  ChatGPTAdapter.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-06.
//

import Foundation

class ChatGPTAdapter {
    struct Config {
        let domain: String?
        let apiKey: String
    }

    let essentialFeature: EssentialFeature
    let config: Config

    init(essentialFeature: EssentialFeature, config: Config) {
        self.essentialFeature = essentialFeature
        self.config = config
    }
}

extension ChatGPTAdapter: ChattingAdapter {
    func sendMessage(message: Message) async throws -> [PlainMessage] {
        guard let chat = message.chat else { return [] }

        let gptMessages = (chat.systemMessage != nil ? [ChatGPTMessage(role: .system, content: chat.systemMessage!)] : []) + (chat.messages + [message]).map({ message in
            ChatGPTMessage.fromMessage(message: message)
        })

        return try await request(messages: gptMessages, temperature: chat.temperature.rawValue).map { gptMessage in
            gptMessage.toPlainMessage(for: chat)
        }
    }

    func validateConfig() async -> Bool {
        do {
            let result = try await request(messages: [.init(role: .user, content: "Test")], temperature: 1)

            return !result.isEmpty
        } catch {
            return false
        }
    }

    func request(messages: [ChatGPTMessage], temperature: Float) async throws -> [ChatGPTMessage] {
        let response: ResponseBody = try await essentialFeature.requestURL(
            urlString: "https://\(config.domain ?? "api.openai.com")/v1/chat/completions",
            init: .init(
                method: .POST,
                body: .json(data: RequestBody(
                    model: .gpt35turbo,
                    messages: messages,
                    temperature: temperature)),
                headers: [
                    "Content-Type": "application/json",
                    "Authorization": "Bearer \(config.apiKey)"
                ]))

        return response.choices.map { choice in
            choice.message
        }
    }

    struct RequestBody: Encodable {
        let model: Model
        let messages: [ChatGPTMessage]
        let temperature: Float

        enum Model: String, Encodable {
            case gpt35turbo = "gpt-3.5-turbo"
        }

    }

    struct ResponseBody: Decodable {
        let id: String
        let object: String
        let created: Int
        let choices: [Choice]
        let usage: Usage

        struct Choice: Decodable {
            let index: Int
            let message: ChatGPTMessage
            let finish_reason: String
        }

        struct Usage: Decodable {
            let prompt_tokens: Int
            let completion_tokens: Int
            let total_tokens: Int
        }
    }

    struct ResponseError: Decodable {
        struct Error: Decodable {
            let message: String?
            let type: String
        }

        let error: Error;
    }

    struct ChatGPTMessage: Codable {
        let role: Role
        let content: String

        enum Role: String, Codable {
            case system = "system"
            case user = "user"
            case assistant = "assistant"
        }

        func toPlainMessage(for chat: Chat) -> PlainMessage {
            var role: Message.Role

            switch(self.role) {
            case .system: role = .system
            case .user: role = .user
            case .assistant: role = .assistant
            }

            return PlainMessage(chat: chat, role: role, content: content)
        }

        static func fromMessage(message: Message) -> ChatGPTMessage {
            var role: Role

            switch(message.role) {
            case .system: role = .system
            case .user: role = .user
            case .assistant: role = .assistant
            }

            return ChatGPTMessage(role: role, content: message.content)
        }
    }
}
