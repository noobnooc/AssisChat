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
        content == nil && !receiving
    }

    var normal: Bool {
        !receiving && !failed
    }

    func markReceiving() {
        tReceiving = true
        chat?.tick()
    }

    func unmarkReceiving() {
        tReceiving = false
        chat?.tick()
    }

    func appendReceivingSlice(slice: String) {
        rawContent = (rawContent ?? "") + slice
    }

    func copyToPasteboard() {
        guard let content = content else { return }

        #if os(iOS)
        UIPasteboard.general.string = content
        #endif

        Haptics.veryLight()
    }

    public override func awakeFromInsert() {
        self.rawTimestamp = Date()
    }
}

// MARK: - Role

extension Message {
    enum Role: Int64 {
        case system = 0
        case user = 1
        case assistant = 2
    }
}
