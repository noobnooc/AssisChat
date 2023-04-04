//
//  SharedUserDefaults.swift
//  AssisChat
//
//  Created by Nooc on 2023-04-04.
//

import Foundation

class SharedUserDefaults {
    static let shared = UserDefaults(suiteName: AppGroup.identifier)!

    static let colorScheme = "settings:colorScheme"
    static let tint = "settings:tint"
    static let symbolVariant = "settings:symbolVariant"
    static let fontSize = "settings:fontSize"
    static let openAIDomain = "settings:openAI:domain"
    static let openAIAPIKey = "settings:openAI:apiKey"
    static let iCloudSync = "settings:iCloudSync"

    static let migrationKey = "dataMigrationComplete"

    static func migrateIfNeeded() {
        // Check if migration has already occurred
        if shared.bool(forKey: migrationKey) {
            return
        }

        // List the keys to migrate
        let keysToMigrate = [
            colorScheme,
            tint,
            symbolVariant,
            fontSize,
            openAIDomain,
            openAIAPIKey,
            iCloudSync,
        ]

        // Migrate the data
        for key in keysToMigrate {
            if let value = UserDefaults.standard.object(forKey: key) {
                shared.set(value, forKey: key)
            }
        }

        // Mark the migration as complete
        shared.set(true, forKey: migrationKey)
    }
}
