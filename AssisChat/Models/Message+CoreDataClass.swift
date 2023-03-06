//
//  Message+CoreDataClass.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//
//

import Foundation
import CoreData

@objc(Message)
public class Message: NSManagedObject {
    var chat: Chat? {
        return rChat;
    }

    var role: Role {
        return Role(rawValue: rawRole) ?? .system
    }

    var content: String {
        return rawContent ?? ""
    }

    var processedContent: String? {
        return rawProcessedContent
    }

    var timestamp: Date {
        return rawTimestamp ?? Date()
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
