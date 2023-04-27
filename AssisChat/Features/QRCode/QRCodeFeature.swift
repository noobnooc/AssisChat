//
//  QRCodeFeature.swift
//  AssisChat
//
//  Created by Nooc on 2023-04-27.
//

import Foundation

class QRCodeFeature: ObservableObject {
    static let codeIdentifier = "ASSISCHAT"

    enum HandlerResult {
        case success(HandledType)
        case error(QRCodeError)
    }

    enum HandledType {
        case config
    }

    enum QRCodeError: Error {
        /// The content of the QRCode is not a valid AssisChat QRCode
        case unidentified
        /// The content seems like a AssisChat QRCode, but cannot to handle
        case unrecognized
        case invalidParams
        case configFailed
    }

    private var settingsFeature: SettingsFeature

    private lazy var supportedHandlers: [String:(_: Dictionary<String, String>) async -> HandlerResult] = [
        "OPENAI": handleOpenAI,
        "ANTHROPIC": handleAnthropic
    ]

    init(settingsFeature: SettingsFeature)  {
        self.settingsFeature = settingsFeature
    }

    func handleString(content: String) async -> HandlerResult {
        let prefix = "\(Self.codeIdentifier):"

        let content = content.trimmingCharacters(in: .whitespacesAndNewlines)

        guard content.hasPrefix(prefix), content.hasSuffix(";;") else {
            return .error(.unidentified)
        }

        let finalContent = content.dropFirst(prefix.count).dropLast()


        let contentDict = finalContent.components(separatedBy: ";").reduce(into: [String: String]()) { (dict, component) in
            let keyValue = component.components(separatedBy: ":")
            if keyValue.count == 2 {
                let key = keyValue[0].uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
                let value = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
                dict[key] = value
            }
        }

        guard let type = contentDict["T"], let handler = supportedHandlers[type] else {
            return .error(.unrecognized)
        }

        return await handler(contentDict)
    }

    func handleOpenAI(params: Dictionary<String, String>) async -> HandlerResult {
        guard let apiKey = params["K"] else {
            return .error(.invalidParams)
        }

        do {
            _ = try await settingsFeature.validateAndConfigOpenAI(apiKey: apiKey, for: params["D"])

            return .success(.config)
        } catch {
            return .error(.configFailed)
        }
    }

    func handleAnthropic(params: Dictionary<String, String>) async -> HandlerResult {
        guard let apiKey = params["K"] else {
            return .error(.invalidParams)
        }

        do {
            _ = try await settingsFeature.validateAndConfigAnthropic(apiKey: apiKey, for: params["D"])

            return .success(.config)
        } catch {
            return .error(.configFailed)
        }
    }
}
