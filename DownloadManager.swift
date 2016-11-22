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
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        let progress : Double = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        //let downloaded =
        

//        NSString* downloaded = [self getReadableFormat:totalBytesWritten];
//        NSString* expectedSize = [self getReadableFormat:totalBytesExpectedToWrite];
//        NSString* size = [NSString stringWithFormat:@"%@/%@",downloaded,expectedSize];
//        
//        TaskWithBlocks* downloadTaskBlock = self.dictOfDownloadTask[@(downloadTask.taskIdentifier)];
//        downloadTaskBlock.progressBlock(progress,(int)downloadTask.taskIdentifier,size);
    }
    
}
