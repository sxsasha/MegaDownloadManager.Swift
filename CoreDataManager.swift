//
//  CoreDataManager.swift
//  MegaDownloadManager.Swift
//
//  Created by admin on 22.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager
{
    var managedObjectContext : NSManagedObjectContext?
    var persistentStoreCoordinator : NSPersistentStoreCoordinator?
    var managedObjectModel : NSManagedObjectModel?
    
    static let sharedManager = CoreDataManager()
    
    init()
    {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        
        let modelURL : URL? = Bundle.main.url(forResource: "Model", withExtension: "momd")
        let SQLURL : URL? = (documentURL?.appendingPathComponent("Download.sqlite"))
        
        if modelURL == nil || SQLURL == nil
        {
           return
        }
        
        managedObjectModel = NSManagedObjectModel.init(contentsOf: modelURL!)
        persistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: managedObjectModel!)
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        
        do
        {
            try persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: SQLURL, options: options)
        }
        catch
        {
            try? FileManager.default.removeItem(at: SQLURL!)
            try? persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: SQLURL, options: nil)
        }
        
        managedObjectContext = NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType(rawValue: UInt(0x02))!)
        managedObjectContext?.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
// MARK: - Work with Core Data Entity
// MARK: -
// MARK: - Work with Data Download
    func addDataDownload() -> (DataDownloadCoreData)
    {
        let newDownload = NSEntityDescription.insertNewObject(forEntityName: "DataDownload", into: managedObjectContext!) as! DataDownloadCoreData
        return newDownload
    }
    
    func deleteAllDataDownload() -> ()
    {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult>  = NSFetchRequest.init(entityName: "DataDownload")
        let allDataDownloads : [DataDownloadCoreData]? = try? managedObjectContext?.fetch(fetchRequest) as! [DataDownloadCoreData]
        
        if allDataDownloads != nil
        {
            for managedObject in allDataDownloads!
            {
                managedObjectContext?.delete(managedObject)
            }
        }
    }
    
    func getAllDataDownloads() -> [DataDownloadCoreData]?
    {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult>  = NSFetchRequest.init(entityName: "DataDownload")
        fetchRequest.includesSubentities = true
        fetchRequest.includesPropertyValues = true
        fetchRequest.returnsObjectsAsFaults = true
        
        let sortDescriptor = NSSortDescriptor.init(key: "number", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let allDataDownloads : [DataDownloadCoreData]? = try? managedObjectContext?.fetch(fetchRequest) as! [DataDownloadCoreData]
        
        return allDataDownloads
    }
    
// MARK: - Work with Search History
    
    func addSearchRequest(string: String, count: Int16, atTime: NSDate) -> SearchHistory
    {
        let newSearchRequest = NSEntityDescription.insertNewObject(forEntityName: "SearchHistory", into: managedObjectContext!) as! SearchHistory
        newSearchRequest.searchString = string
        newSearchRequest.getCount = count
        newSearchRequest.time = atTime
        
        save()
        return newSearchRequest
    }
    
    func getAllSearchHistory() -> [SearchHistory]?
    {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult>  = NSFetchRequest.init(entityName: "SearchHistory")
        
        fetchRequest.includesSubentities = true
        fetchRequest.includesPropertyValues = true
        fetchRequest.returnsObjectsAsFaults = true
        
        let allSearchHistory : [SearchHistory]? = try? managedObjectContext?.fetch(fetchRequest) as! [SearchHistory]
        
        return allSearchHistory
    }
    func deleteAllSearchHistory() -> ()
    {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult>  = NSFetchRequest.init(entityName: "SearchHistory")
        let allSearchHistory : [SearchHistory]? = try? managedObjectContext?.fetch(fetchRequest) as! [SearchHistory]
        
        if allSearchHistory != nil
        {
            for managedObject in allSearchHistory!
            {
                managedObjectContext?.delete(managedObject)
            }
        }
        
    }
// MARK: - Work with Main Method
    func deleteEntity(object : NSManagedObject) -> ()
    {
        managedObjectContext?.delete(object)
    }
    
    func save () -> ()
    {
        let ourRootController : UINavigationController = UIApplication.shared.windows.first?.rootViewController as!UINavigationController
        let ourViewController : ViewController =  ourRootController.viewControllers.first as! ViewController
        
        var i : Int = 0
        for dataDownload in ourViewController.arrayOfDataDownload
        {
            dataDownload.dataDownloadCoreData?.number = Int16(i)
            i += 1
        }
        
        do
        {
            try managedObjectContext?.save()
        } catch
        {
            // handle error
        }
    }
}
