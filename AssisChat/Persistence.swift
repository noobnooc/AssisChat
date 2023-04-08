//
//  Persistence.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import CoreData
import Combine

class PersistenceController {
    static let shared = PersistenceController()

    static private let fileName = "AssisChat.sqlite"

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    private let containerOptions: NSPersistentCloudKitContainerOptions?
    let container: NSPersistentCloudKitContainer
    private var mergeRemoteChangesCancelable: AnyCancellable?

    init(inMemory: Bool = false) {
        var container = NSPersistentCloudKitContainer(name: "AssisChat")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        let legacyURL = container.persistentStoreDescriptions.first?.url;

        if let legacyPath = legacyURL?.path, FileManager.default.fileExists(atPath: legacyPath) {
            container.loadPersistentStores { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }

            container = NSPersistentCloudKitContainer(name: "AssisChat")
        }

        // Configure the persistent store description to use the shared app group container
        if let storeDescription = container.persistentStoreDescriptions.first {
            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroup.identifier) {
                let storeURL = url.appendingPathComponent(Self.fileName)

                storeDescription.url = storeURL
            }
        }

        self.container = container

        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        container.persistentStoreDescriptions.first?.setOption(true as NSNumber,
                                                               forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)

        containerOptions = container.persistentStoreDescriptions.first?.cloudKitContainerOptions

        if(!SharedUserDefaults.shared.bool(forKey: SharedUserDefaults.iCloudSync)){
            container.persistentStoreDescriptions.first?.cloudKitContainerOptions = nil
        }

        migrateStoreIfNeeded(for: container, legacyURL: legacyURL)

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        try? container.viewContext.setQueryGenerationFrom(.current)


        mergeRemoteChangesCancelable = NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange, object: nil)
            .sink { notification in
                let context = self.container.viewContext

                // Merge changes from the notification
                context.perform {
                    context.mergeChanges(fromContextDidSave: notification)
                }
            }

    }

    func setupCloudSync(sync: Bool) {
        // TODO: - Implements
    }

    private func migrateStoreIfNeeded(for container: NSPersistentContainer, legacyURL: URL?) {
        guard
            let legacyURL = legacyURL,
            let currentURL = container.persistentStoreDescriptions.first?.url
        else { return }

        if FileManager.default.fileExists(atPath: legacyURL.path),
           !FileManager.default.fileExists(atPath: currentURL.path) {
            do {
                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: container.managedObjectModel)
                let store = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: legacyURL, options: nil)
                try coordinator.migratePersistentStore(store, to: currentURL, options: nil, withType: NSSQLiteStoreType)
            } catch {
                fatalError("Failed to migrate store: \(error)")
            }
        }
    }
}
