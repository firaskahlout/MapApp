//
//  DataManager.swift
//  MapApp
//
//  Created by Firas AlKahlout on 9/12/20.
//  Copyright © 2020 Firas Alkahlout. All rights reserved.
//

import Foundation
import CoreData

final class DataManager {
    
    private init() {}
    static let shared = DataManager()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MapApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
        save()
    }
    
    // MARK: - Core Data Saving support
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
                print("This operation saved successfully")
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    // MARK: - Core Data Fetching Data
    
    func fetch<T: NSManagedObject>(_ type: T.Type) -> [T]? {
        guard
            let fetchRequest = try? context.fetch(T.fetchRequest()),
            let dataList = fetchRequest as? [T]
        else { return nil }
        return dataList
    }
}
