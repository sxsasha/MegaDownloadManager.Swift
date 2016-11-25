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

class DataDownload : NSObject
{
    var name : String?{
        didSet
        {
            dataDownloadCoreData?.name = name
        }
    }
    var localName : String? {
        didSet
        {
            dataDownloadCoreData?.localName = localName
        }
    }
    var identifier : Int?
    var urlString : String? {
    didSet
    {
        if self.name == nil
        {
            let tempName = urlString?.removingPercentEncoding
            let nameNSString = tempName as NSString?
            self.name = nameNSString?.lastPathComponent
        }
        if self.localName == nil
        {
            let url = URL.init(string: urlString!)
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

            let isHaveSpace =  tempLocalName!.components(separatedBy: characters as CharacterSet)
            self.localName = isHaveSpace.joined(separator: "_")
        }
        //create localURL (where save)
        self.localURL = documentURL?.appendingPathComponent(self.localName!).absoluteString
        self.dataDownloadCoreData?.urlString = urlString
        self.coreDataManager.save()
    }
    }
    var localURL : String?
    var progress : Float = 0.0{
        didSet
        {
            let percent = (progress*100 < 0) || (progress*100 > 100) ? 0.0 : progress*100
            DispatchQueue.main.async {
                self.cell?.progressLabel.text = String.init(format: "%.2f", percent)
                self.cell?.progressView.setProgress(Float(self.progress), animated: false)
            }

        }
    }
    var downloaded : String = "" {
        didSet
        {
            DispatchQueue.main.async {
                self.cell?.sizeProgressLabel.text = self.downloaded
            }
        }
    }
    var isComplate : Bool = false{
        didSet
        {
            if self.isComplate
            {
                DispatchQueue.main.async {
                    self.cell?.progressLabel.text = String.init(format: "%.2f", 100.0)
                    self.cell?.progressView.setProgress(1.0, animated: false)
                    self.cell?.pauseImageView.isHidden = true
                }
            }
        }
    }
    var isDownloading : Bool = false{
        didSet
        {
            DispatchQueue.main.async {
                if self.isDownloading
                {
                    self.cell?.pauseImageView.image = UIImage(named: "download.png")
                    self.cell?.pauseImageView.isHidden = false
                }
            }
        }
    }
    var isPause : Bool = false{
        didSet
        {
            DispatchQueue.main.async {
                if self.isPause
                {
                    self.cell?.pauseImageView.image = UIImage(named: "pause.png")
                    self.cell?.pauseImageView.isHidden = false
                }
                else if self.isDownloading
                {
                    self.cell?.pauseImageView.image = UIImage(named: "download.png")
                    self.cell?.pauseImageView.isHidden = false
                }
                else
                {
                    self.cell?.pauseImageView.isHidden = true
                }
            }
        }
    }
    
    var cellAccessoryType : UITableViewCellAccessoryType = .none

    var cell : DownloadCell? = nil
    
    var dataDownloadCoreData : DataDownloadCoreData?
    var coreDataManager : CoreDataManager = CoreDataManager.sharedManager
    var downloadTask : URLSessionDownloadTask?
    
    override init()
    {
        super.init()
        dataDownloadCoreData = coreDataManager.addDataDownload()
    }
    
    init(withDownloads coreDataDownload: DataDownloadCoreData)
    {
        super.init()
        self.initWith(coreDataDownload: coreDataDownload)
    }
    
    func initWith(coreDataDownload: DataDownloadCoreData) -> ()
    {
        self.dataDownloadCoreData = coreDataDownload
        self.name = coreDataDownload.name
        self.localName = coreDataDownload.localName
        self.urlString = coreDataDownload.urlString
        
        if checkIfWeHaveSomeFile(urlString: self.localURL!)
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
    
    func checkIfWeHaveSomeFile(urlString: String) -> Bool
    {
        let url = URL.init(string: urlString)
        
        return FileManager.default.fileExists(atPath: (url?.relativePath)!)
    }
}
