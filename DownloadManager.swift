//
//  DownloadManager.swift
//  MegaDownloadManager.Swift
//
//  Created by admin on 22.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class DownloadManager : NSObject, URLSessionDelegate
{
    var defaultSession : URLSession?
    var dictOfDownloadTask : Dictionary<String,Any> = Dictionary()
    
    static let sharedManager = GoogleSearchPDF()
    
    override init()
    {
        super.init()
        var sessionConfig = URLSessionConfiguration.default
        sessionConfig.allowsCellularAccess = true
        sessionConfig.timeoutIntervalForRequest = 0
        sessionConfig.timeoutIntervalForResource = 0
        
        var ourQueue = OperationQueue()
        ourQueue.maxConcurrentOperationCount = 10
        
        self.defaultSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: ourQueue)
    }
    func downloadWithURL(url url:String) -> URLSessionDownloadTask
    {
        <#function body#>
    }
    
}
