//
//  ChatGPTAdapter.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-06.
//

import Foundation
import LDSwiftEventSource
import Combine
import SwiftUI
import GPT3_Tokenizer

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
    var priority: Int {
        1
    }

    var identifier: String {
        "openai"
    }

    var models: [String] {
        Chat.OpenAIModel.allCases.map { model in
            model.rawValue
        }
    }

    var defaultModel: String {
        Chat.OpenAIModel.default.rawValue
    }

    func sendMessageWithStream(chat: Chat, receivingMessage: Message) async throws {
        do {
            try await requestStream(messages: retrieveGPTMessages(chat: chat, receivingMessage: receivingMessage), for: receivingMessage)
        } catch {
            if let error = error as? UnsuccessfulResponseError {
                let reason = convertStatusCodeToFailedReason(statusCode: error.responseCode)
                receivingMessage.failedReason = reason
                essentialFeature.persistData()
            } else {
                let error = error as NSError

                let reason: Message.FailedReason = error.domain == NSURLErrorDomain ? .network : .unknown
                receivingMessage.failedReason = reason
                essentialFeature.persistData()

                essentialFeature.appendAlert(alert: ErrorAlert(message: LocalizedStringKey(error.localizedDescription)))
            }
        }
    }

    func sendMessage(message: Message) async throws -> [PlainMessage] {
        guard let chat = message.chat else { return [] }

        // TODO: - The `receivingMessage: message` parament is for avoid error, it is not work
        return try await request(messages: retrieveGPTMessages(chat: chat, receivingMessage: message), model: Chat.OpenAIModel.default.rawValue, temperature: chat.temperature.rawValue).map { gptMessage in
            gptMessage.toPlainMessage(for: chat)
        }
    }

    func validateConfig() async throws {
        do {
            let result = try await request(messages: [.init(role: .user, content: "Test")], model: Chat.OpenAIModel.default.rawValue, temperature: 1)

            if result.isEmpty {
                throw ChattingError.validating(message: "Unknown error")
            }
        } catch ChattingError.sending(message: let message) {
            throw ChattingError.validating(message: message)
        } catch GeneralError.badURL {
            throw ChattingError.validating(message: "Invalid URL")
        } catch {
            throw error
        }
    }

    func requestStream(messages: [ChatGPTMessage], for message: Message) async throws {
        guard let chat = message.chat else { return }

        let handler = Handler()
        var config = EventSource.Config(handler: handler, url: URL(string: "https://\(config.domain ?? "api.openai.com")/v1/chat/completions")!)

        config.method = "POST"
        config.headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(self.config.apiKey)"
        ]
        config.body = try? JSONEncoder().encode(RequestBody(
            model: chat.openAIModel.rawValue,
            messages: messages,
            temperature: chat.temperature.rawValue,
            stream: true)
        )

        var cancelable: AnyCancellable?
        let eventSource = EventSource(config: config)

        try await withCheckedThrowingContinuation { continuation in
            cancelable = handler.publisher.sink { completion in
                eventSource.stop()

                switch completion {
                case .finished: continuation.resume()
                case .failure(let error):
                    continuation.resume(with: .failure(error))
                }
            } receiveValue: { value in
                message.appendReceivingSlice(slice: value)
                self.essentialFeature.persistData()
            }

            eventSource.start()
        }
    }

    func request(messages: [ChatGPTMessage], model: String, temperature: Float) async throws -> [ChatGPTMessage] {
        let response: EssentialFeature.Response<ResponseBody, ResponseError> = try await essentialFeature.requestURL(
            urlString: "https://\(config.domain ?? "api.openai.com")/v1/chat/completions",
            init: .init(
                method: .POST,
                body: .json(data: RequestBody(
                    model: model,
                    messages: messages,
                    temperature: temperature,
                    stream: false)),
                headers: [
                    "Content-Type": "application/json",
                    "Authorization": "Bearer \(config.apiKey)"
                ]))

        guard let responseData = response.data else {
            let errorMessage = response.error?.error.message ?? "Unknown error"

            if response.response?.statusCode == 401 {
                throw ChattingError.validating(message: "Unauthenticated request")
            }

            throw ChattingError.sending(message: LocalizedStringKey(errorMessage))
        }

        return responseData.choices.map { choice in
            choice.message
        }
    }

    private func convertStatusCodeToFailedReason(statusCode: Int) -> Message.FailedReason {
        switch statusCode {
        case 401: return .authentication
        case 429: return .rateLimit
        case 400...499: return .client
        case 500...599: return .server
        default: return .unknown
        }
    }

    private func retrieveGPTMessages(chat: Chat, receivingMessage: Message) -> [ChatGPTMessage] {
        let maxTokens = chat.openAIModel.maxTokens

        let systemMessages: [ChatGPTMessage]
        var currentTokens: Int

        if let chatSystemMessage = chat.systemMessage {
            systemMessages = [ChatGPTMessage(role: .system, content: chatSystemMessage)]
            currentTokens = calculateTokens(text: chatSystemMessage)
        } else {
            systemMessages = []
            currentTokens = 0
        }

        let receivingMessageIndex = chat.messages.lastIndex(of: receivingMessage) ?? chat.messages.count
        let historyMessagesReadyToSend = Array(chat.messages.prefix(receivingMessageIndex).suffix(Int(chat.historyLengthToSend)))

        var historyMessagesToSend: [ChatGPTMessage] = []

        for message in historyMessagesReadyToSend.reversed() {
            currentTokens += calculateTokens(text: message.rawProcessedContent ?? message.content ?? "")

            guard currentTokens < maxTokens else {
                break
            }

            historyMessagesToSend.append(ChatGPTMessage.fromMessage(message: message))
        }

        historyMessagesToSend = historyMessagesToSend.reversed()

        return systemMessages + historyMessagesToSend
    }

    struct RequestBody: Encodable {
        let model: String
        let messages: [ChatGPTMessage]
        let temperature: Float
        let stream: Bool
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
            let finish_reason: String?
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

            return PlainMessage(chat: chat, role: role, content: content, processedContent: nil)
        }

        static func fromMessage(message: Message) -> ChatGPTMessage {
            var role: Role

            switch(message.role) {
            case .system: role = .system
            case .user: role = .user
            case .assistant: role = .assistant
            }

            return ChatGPTMessage(role: role, content: message.processedContent ?? message.content ?? "")
        }
    }
}

private struct Handler: EventHandler {
    struct MessageData: Decodable {
        let choices: [Choice]

        struct Choice: Decodable {
            let delta: Delta

            struct Delta: Decodable {
                let content: String
            }
        }
    }

    let publisher = PassthroughSubject<String, Error>()

    func onOpened() {
    }

    func onClosed() {
        publisher.send(completion: .finished)
    }

    func onComment(comment: String) {
    }

    func onError(error: Error) {
        publisher.send(completion: .failure(error))
    }

    func onMessage(eventType: String, messageEvent: MessageEvent) {
        guard messageEvent.data != "[DONE]" else {
            publisher.send(completion: .finished)
            return
        }

        guard
            let data = messageEvent.data.data(using: .utf8),
            let decodedData = try? JSONDecoder().decode(MessageData.self, from: data),
            let content = decodedData.choices.first?.delta.content
        else {
            return
        }

        publisher.send(content)
    }
}

private func calculateTokens(text: String) -> Int {
    let gpt3Tokenizer = GPT3Tokenizer()
    let encoded = gpt3Tokenizer.encoder.enconde(text: text)

    return encoded.count
}
