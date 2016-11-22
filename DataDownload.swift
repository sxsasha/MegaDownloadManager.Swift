//
//  DataDownload.swift
//  MegaDownloadManager.Swift
//
//  Created by admin on 22.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last

class DataDownload
{
    var name : String?
    var identifier : Int16?
    var urlString : String? {
    set
    {
        if self.name != nil
        {
            let url = URL.init(string: newValue!)
            var name = url?.lastPathComponent

            if (name!.hasSuffix(".pdf"))
            {
                name = name?.appending(".pdf")
            }
            
            let isHaveSpace =  name!.components(separatedBy:" ")
            self.name = isHaveSpace.joined(separator: "_")
        }
        
    }
        get{return self.urlString}
    }
    var localURL : String?
    var progress : Double?
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
