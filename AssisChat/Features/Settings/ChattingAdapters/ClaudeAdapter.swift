//
//  ClaudeAdapter.swift
//  AssisChat
//
//  Created by Nooc on 2023-04-17.
//

import Foundation
import LDSwiftEventSource
import Combine
import SwiftUI
import GPT3_Tokenizer

class ClaudeAdapter {
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

extension ClaudeAdapter: ChattingAdapter {
    var priority: Int {
        2
    }

    var identifier: String {
        "anthropic"
    }

    var models: [String] {
        return Chat.ClaudeModel.allCases.map { model in
            model.rawValue
        }
    }

    var defaultModel: String {
        return Chat.ClaudeModel.default.rawValue
    }

    func sendMessageWithStream(chat: Chat, receivingMessage: Message) async throws {
        do {
            try await requestStream(prompt: retrievePrompt(chat: chat, receivingMessage: receivingMessage), for: receivingMessage)
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
        let content = try await request(prompt: retrievePrompt(chat: chat, receivingMessage: message), model: Chat.ClaudeModel.default, temperature: chat.temperature.claude)

        let plainMessage = PlainMessage(chat: chat, role: .assistant, content: content, processedContent: nil)

        return [plainMessage]
    }

    func validateConfig() async throws {
        do {
            let result = try await request(prompt: "\n\nHuman: Hello\n\nAssistant: ", model: Chat.ClaudeModel.default, temperature: 1)

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

    func requestStream(prompt: String, for message: Message) async throws {
        guard let chat = message.chat else { return }

        let handler = Handler()
        var config = EventSource.Config(handler: handler, url: URL(string: "https://\(config.domain ?? "api.anthropic.com")/v1/complete")!)

        config.method = "POST"
        config.headers = [
            "Content-Type": "application/json",
            "x-api-key": self.config.apiKey
        ]
        config.body = try? JSONEncoder().encode(RequestBody(
            prompt: prompt,
            model: chat.claudeModel.rawValue,
            maxTokens: chat.claudeModel.maxTokens,
            temperature: chat.temperature.claude,
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
                message.replaceReceivingContent(content: value)
                self.essentialFeature.persistData()
            }

            eventSource.start()
        }
    }

    func request(prompt: String, model: Chat.ClaudeModel, temperature: Float) async throws -> String {
        let response: EssentialFeature.Response<ResponseBody, ResponseError> = try await essentialFeature.requestURL(
            urlString: "https://\(config.domain ?? "api.anthropic.com")/v1/complete",
            init: .init(
                method: .POST,
                body: .json(data: RequestBody(
                    prompt: prompt,
                    model: model.rawValue,
                    maxTokens: model.maxTokens,
                    temperature: temperature,
                    stream: false)),
                headers: [
                    "Content-Type": "application/json",
                    "x-api-key": self.config.apiKey
                ]))

        guard let responseData = response.data, response.response?.statusCode == 200 else {
            let errorMessage = response.error?.details ?? "Unknown error"

            if response.response?.statusCode == 401 {
                throw ChattingError.validating(message: "Unauthenticated request")
            }

            throw ChattingError.sending(message: LocalizedStringKey(errorMessage))
        }

        return responseData.completion ?? ""
    }

    private func convertStatusCodeToFailedReason(statusCode: Int) -> Message.FailedReason {
        switch statusCode {
        case 401: return .authentication
        case 403: return .network
        case 429: return .rateLimit
        case 400...499: return .client
        case 500...599: return .server
        default: return .unknown
        }
    }

    private func retrievePrompt(chat: Chat, receivingMessage: Message) -> String {
        let maxTokens = chat.openAIModel.maxTokens

        let chatSystemMessage = chat.systemMessage
        var currentTokens = 0
        var systemPrompt = ""
        var prompt = ""

        if let chatSystemMessage = chatSystemMessage {
            currentTokens = calculateTokens(text: chatSystemMessage)
            systemPrompt = "\n\nHuman: \(chatSystemMessage)\n\nAssistant: OK"
        }

        let receivingMessageIndex = chat.messages.lastIndex(of: receivingMessage) ?? chat.messages.count
        let historyMessagesReadyToSend = Array(chat.messages.prefix(receivingMessageIndex).suffix(Int(chat.historyLengthToSend)))

        for message in historyMessagesReadyToSend.reversed() {
            currentTokens += calculateTokens(text: message.rawProcessedContent ?? message.content ?? "")

            guard currentTokens < maxTokens else {
                break
            }

            if message.role == .assistant {
                prompt = "\n\nAssistant: \(message.processedContent ?? message.content ?? "")" + prompt
            } else {
                prompt = "\n\nHuman: \(message.processedContent ?? message.content ?? "")" + prompt
            }
        }

        prompt = systemPrompt + prompt + "\n\nAssistant: "

        return prompt
    }

    struct RequestBody: Encodable {
        let prompt: String
        let model: String
        let maxTokens: Int
        let stopSequences = ["\n\nHuman:"]
        let temperature: Float
        let stream: Bool

        enum CodingKeys: String, CodingKey {
            case prompt = "prompt"
            case model = "model"
            case maxTokens = "max_tokens_to_sample"
            case stopSequences = "stop_sequences"
            case temperature = "temperature"
            case stream = "stream"
        }
    }

    struct ResponseBody: Decodable {
        let completion: String?
    }

    struct ResponseError: Decodable {
        let details: String?
    }
}

private struct Handler: EventHandler {
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
            let decodedData = try? JSONDecoder().decode(ClaudeAdapter.ResponseBody.self, from: data),
            let content = decodedData.completion
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
