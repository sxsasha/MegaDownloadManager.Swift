//
//  SearchHistory+CoreDataProperties.swift
//  MegaDownloadManager.Swift
//
//  Created by admin on 22.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

import Foundation
import CoreData


extension SearchHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchHistory> {
        return NSFetchRequest<SearchHistory>(entityName: "SearchHistory");
    }

    @NSManaged public var getCount: Int16
    @NSManaged public var searchString: String?
    @NSManaged public var time: NSDate?

}
