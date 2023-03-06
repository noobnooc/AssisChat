//
//  Dictionary+Extensions.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import Foundation
import CoreData


// MARK: - CoreData
extension Dictionary where Key == AnyHashable {
    func value<T>(for key: NSManagedObjectContext.NotificationKey) -> T? {
        return self[key.rawValue] as? T
    }
}

