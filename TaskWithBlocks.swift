//
//  TaskWithBlocks.swift
//  MegaDownloadManager.Swift
//
//  Created by admin on 22.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

typealias ProgressBlock = (Double, Int, String) -> Void
typealias ComplateBlock = (Int, URL) -> Void
typealias ErrorBlock = (Error) -> Void

class TaskWithBlocks
{
    var progressBlock : ProgressBlock?
    var complateBlock : ComplateBlock?
    var errorBlock : ErrorBlock?
    
    var downloadTask : URLSessionDownloadTask?
}
