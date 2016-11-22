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
    var dictOfDownloadTask : NSMutableDictionary = NSMutableDictionary()
    
    static let sharedManager = GoogleSearchPDF()
    
    override init()
    {
        super.init()
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.allowsCellularAccess = true
        sessionConfig.timeoutIntervalForRequest = 0
        sessionConfig.timeoutIntervalForResource = 0
        
        let ourQueue = OperationQueue()
        ourQueue.maxConcurrentOperationCount = 10
        
        self.defaultSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: ourQueue)
    }
    
    func downloadWithURL(url urlString:String, progressBlock:@escaping ProgressBlock, complateBlock : @escaping ComplateBlock, errorBlock: @escaping ErrorBlock) -> URLSessionDownloadTask?
    {
        let url = URL(string: urlString)
        
        if url != nil
        {
            let urlRequest = URLRequest(url: url!)
            let sessionTask = self.defaultSession?.downloadTask(with: urlRequest)
            
            let downloadTaskBlock = TaskWithBlocks()
            downloadTaskBlock.progressBlock = progressBlock
            downloadTaskBlock.complateBlock = complateBlock
            downloadTaskBlock.errorBlock = errorBlock
            downloadTaskBlock.downloadTask = sessionTask
            
            self.dictOfDownloadTask.setObject(downloadTaskBlock, forKey: (sessionTask?.taskIdentifier)! as NSCopying)
            sessionTask?.taskDescription = urlString
            sessionTask?.resume()
            return sessionTask
        }
        return nil
    }
    
    // #MARK: - URLSessionTaskDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        let downloadTaskBlock : TaskWithBlocks = dictOfDownloadTask.object(forKey: task.taskIdentifier) as! TaskWithBlocks
        if error != nil
        {
            downloadTaskBlock.errorBlock?(error!)
        }
        
        dictOfDownloadTask.removeObject(forKey: task.taskIdentifier)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        let downloadTaskBlock : TaskWithBlocks = dictOfDownloadTask.object(forKey: downloadTask.taskIdentifier) as! TaskWithBlocks
        downloadTaskBlock.complateBlock?(downloadTask.taskIdentifier, location)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        let progress : Double = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        let downloaded = getReadableFormat(bytes: totalBytesWritten)
        let expectedSize = getReadableFormat(bytes: totalBytesExpectedToWrite)
        let size = String.init(format: "%@/%@", downloaded, expectedSize)
        
        let downloadTaskBlock : TaskWithBlocks = self.dictOfDownloadTask.object(forKey: downloadTask.taskIdentifier) as! TaskWithBlocks
        downloadTaskBlock.progressBlock?(progress,downloadTask.taskIdentifier,size)
    }
    
    // #MARK: - Help Methods
    func getReadableFormat(bytes: Int64) -> String
    {
        let array = ["b","kb","mb","gb","gb","tb","pb"]
        var xBytes = Double(bytes)
        var i = 0
        while xBytes > 1024
        {
            xBytes = xBytes / 1024.0
            i = i + 1
        }
        
        if i >= array.count
        {
            i = array.count - 1
        }
        return String.init(format: "%d%@", Int(xBytes),array[i])
    }
    
}
