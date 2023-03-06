//
//  Notification+Extensions.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import Foundation
import CoreData


// MARK: - CoreData
extension Notification {
    var insertedObjects: Set<NSManagedObject>? {
        return userInfo?.value(for: .insertedObjects)
    }

    var updatedObjects: Set<NSManagedObject>? {
        return userInfo?.value(for: .updatedObjects)
    }

    var deletedObjects: Set<NSManagedObject>? {
        return userInfo?.value(for: .deletedObjects)
    }
}

