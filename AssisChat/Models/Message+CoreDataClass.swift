//
//  Message+CoreDataClass.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//
//

import Foundation
import CoreData

#if os(iOS)
import UIKit
#endif

@objc(Message)
public class Message: NSManagedObject {
    var chat: Chat? {
        return rChat;
    }

    var role: Role {
        return Role(rawValue: rawRole) ?? .system
    }

    var content: String? {
        return rawContent
    }

    var processedContent: String? {
        return rawProcessedContent
    }

    var timestamp: Date {
        return rawTimestamp ?? Date()
    }

    var receiving: Bool {
        tReceiving
    }

    var failed: Bool {
        failedReason != nil
    }

    var normal: Bool {
        !receiving && !failed
    }

    func markReceiving() {
        tReceiving = true
        chat?.touch()
    }

    func unmarkReceiving() {
        tReceiving = false
        chat?.touch()
    }

    func appendReceivingSlice(slice: String) {
        rawContent = (rawContent ?? "") + slice
    }

    func replaceReceivingContent(content: String) {
        rawContent = content
    }

    func copyToPasteboard() {
        guard let content = content else { return }

        Clipboard.copyToClipboard(text: content)
    }

    public override func awakeFromInsert() {
        self.rawTimestamp = Date()
        self.chat?.touch()
    }
}

// MARK: - Role

extension Message {
    enum Role: Int16 {
        case system = 0
        case user = 1
        case assistant = 2
    }
}

// MARK: - FailedReason

extension Message {
    var failedReason: FailedReason? {
        get {
            guard content == nil, !receiving else { return nil }
            
            guard let reasonString = rawFailedReason else { return .unknown }
            
            return FailedReason(rawValue: reasonString) ?? .unknown
        }

        set {
            rawFailedReason = newValue?.rawValue
        }
    }

    enum FailedReason: String, RawRepresentable {
        case unknown = "unknown"
        case network = "network"
        case authentication = "authentication"
        case rateLimit = "rate-limit"
        case client = "client"
        case server = "server"

        var localized: String {
            switch self {
            case .unknown: return String(localized: "Unknown Error", comment: "The unknown error of message failed reason")
            case .network: return String(localized: "Network Error", comment: "The network error of message failed reason")
            case .authentication: return String(localized: "Authentication Failed", comment: "The authentication error of message failed reason")
            case .rateLimit: return String(localized: "Rate Limited", comment: "The rate limited error of message failed reason")
            case .client: return String(localized: "Unknown Client Error", comment: "The unknown client error of message failed reason")
            case .server: return String(localized: "Server Error", comment: "The server error of message failed reason")
            }
        }
    }
}
