//
//  DataDownload+CoreDataProperties.swift
//  MegaDownloadManager.Swift
//
//  Created by admin on 22.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

import Foundation
import CoreData


extension DataDownloadCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataDownloadCoreData>
    {
        return NSFetchRequest<DataDownloadCoreData>(entityName: "DataDownload");
    }

    @NSManaged public var name: String?
    @NSManaged public var urlString: String?

}
