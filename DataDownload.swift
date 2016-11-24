//
//  DataDownload.swift
//  MegaDownloadManager.Swift
//
//  Created by admin on 22.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last

func getAllDataDownloadFromaDatabase() -> [DataDownload]
{
    let dataDownloadsFromDatabase = CoreDataManager.sharedManager.getAllDataDownloads()
    
    var array = [DataDownload]()
    for obj in dataDownloadsFromDatabase!
    {
        let dataDownload = DataDownload(withDownloads: obj)
        array.append(dataDownload)
    }
    return array
}

class DataDownload
{
    var name : String?{
        set
        {
            dataDownloadCoreData?.name = newValue
        }get
        {
            return self.name
        }
    }
    var localName : String? {
        set
        {
            dataDownloadCoreData?.localName = newValue
        }get
        {
            return self.localName
        }
    }
    var identifier : Int?
    var urlString : String? {
    set
    {
        if self.name == nil
        {
            let name = newValue?.removingPercentEncoding
            let url = URL.init(string: name!)
            self.name = url?.lastPathComponent
        }
        if self.localName == nil
        {
            let url = URL.init(string: newValue!)
            var tempLocalName = url?.lastPathComponent
            
            if (tempLocalName?.characters.count)! < 5
            {
                tempLocalName = tempLocalName?.appending(".pdf")
            }
            else
            {
                if (tempLocalName!.hasSuffix(".pdf"))
                {
                    tempLocalName = tempLocalName?.appending(".pdf")
                }
            }
            
            let characters : NSMutableCharacterSet = NSMutableCharacterSet.alphanumeric()
            characters.addCharacters(in:".")
            characters.invert()

            let isHaveSpace =  localName!.components(separatedBy: characters as CharacterSet)
            self.name = isHaveSpace.joined(separator: "_")
        }
        //create localURL (where save)
        self.localURL = documentURL?.appendingPathComponent(self.localName!).absoluteString
        self.dataDownloadCoreData?.urlString = newValue
        self.coreDataManager.save()
        
    }
        get{return self.urlString}
    }
    var localURL : String?
    var progress : Float?
    var downloaded : String?
    var isComplate : Bool = false
    var isDownloading : Bool = false
    var isPause : Bool = false
    
    var dataDownloadCoreData : DataDownloadCoreData?
    var coreDataManager : CoreDataManager = CoreDataManager.sharedManager
    var downloadTask : URLSessionDownloadTask?
    
    init()
    {
        dataDownloadCoreData = coreDataManager.addDataDownload()
    }
    
    init(withDownloads dataDownload: DataDownloadCoreData)
    {
        dataDownloadCoreData = dataDownload
        name = dataDownload.name
        urlString = dataDownload.urlString
        
        if checkIfWeHaveSomeFile(name: name!)
        {
            isComplate = true
            progress = 1.0
        }
    }
    
// MARK: - Help Methods
 
    func removeFromDatabase() -> ()
    {
        if localURL != nil
        {
            coreDataManager.deleteEntity(object: dataDownloadCoreData!)
            let localURL = URL.init(string: self.localURL!)
            try? FileManager.default.removeItem(at: localURL!)
            dataDownloadCoreData = nil
            coreDataManager.save()
        }
    }
    
    func checkIfWeHaveSomeFile(name: String) -> Bool
    {
        let localURL = documentURL?.appendingPathComponent(name).relativeString ///???

        if (FileManager.default.fileExists(atPath: localURL!))
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    
    
}
