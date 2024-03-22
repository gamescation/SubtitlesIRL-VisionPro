//
//  CoreDataService.swift
//  SubtitlesIRL
//
//  Created by David on 3/19/24.
//

import Foundation
import CoreData

class CoreDataService {
    static func clearAllData(entity: String) {
        let managedContext = CoreDataManager.shared.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.includesPropertyValues = false // Only fetch the managedObjectID

        do {
            let items = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for item in items {
                managedContext.delete(item)
            }

            // Save the context to apply the delete.
            try managedContext.save()
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
}
