//
//  DataDownload+CoreDataProperties.swift
//  MegaDownloadManager.Swift
//
//  Created by admin on 23.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

import Foundation
import CoreData


extension DataDownload {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataDownload> {
        return NSFetchRequest<DataDownload>(entityName: "DataDownload");
    }

    @NSManaged public var name: String?
    @NSManaged public var urlString: String?
    @NSManaged public var localName: NSObject?

}
