//
//  GoogleSearchPDF.swift
//  MegaDownloadManager.Swift
//
//  Created by admin on 18.11.16.
//  Copyright © 2016 admin. All rights reserved.
//


import UIKit

let GoogleAPI = "AIzaSyBIhTNx9XFK3dlLfKHRgnL8Ucx-8juCqbk"
let GoogleSearchID = "013242499754616033066:azpci6bcd9s"

protocol GotPDFLinksDelegate
{
    func givePDFLink(link: [String?]) -> ()
    func errorWithSearchString(string: String?) -> ()
}

class GoogleSearchPDF
{
    static let sharedManager = GoogleSearchPDF()
    
    var delegate : GotPDFLinksDelegate?
    var dataTask : URLSessionDataTask?
    var arrayOfSearchHistory: NSMutableArray = NSMutableArray()
    let myQueue : DispatchQueue? = DispatchQueue(label: "GoogleSearchPDF")
    //static let coreDataManager : CoreDataManager.sharedManager
    
    func getTenPDFLinksWithSearchString(searchString: String ) -> ()
    {
        self.myQueue?.async{
            self.createRequest(searchString: searchString)
        }
    }
    
    func createRequest(searchString : String) -> ()
    {
        //    SearchHistory* foundHistory = nil;
        //    for (SearchHistory* history in self.arrayOfSearchHistory)
        //    {
        //    if([history.searchString isEqualToString:searchString])
        //    {
        //    history.getCount = history.getCount + 10;
        //    history.time = [NSDate date];
        //    foundHistory = history;
        //    break;
        //    }
        //    }
        //    if (!foundHistory)
        //    {
        //    foundHistory = [self.coreDataManager addSearchRequest:searchString count:1 atTime:[NSDate date]];
        //    [self.arrayOfSearchHistory addObject:foundHistory];
        //    }
        //
        let string = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
        
        let urlString = String.init(format: "https://www.googleapis.com/customsearch/v1?q=%@&fileType=pdf&filter=1&cx=%@&key=%@&start=%d", string! ,GoogleSearchID,GoogleAPI,1)
        let url = URL(string: urlString)
        
        if let staticURL = url
        {
            let urlRequest = URLRequest(url: staticURL, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30.0)
            URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, urlResponse, error) in
                if data != nil
                {
                    let dictionary = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    if dictionary != nil
                    {
                        self.parseDict(dict: dictionary as! Dictionary<String, Array<Dictionary<String, String>>>)
                    }
                }
            })
        }
        else
        {
            delegate?.errorWithSearchString(string: string)
        }
       
    }
    func parseDict(dict: Dictionary <String,Array<Dictionary<String,String>>>) -> ()
    {
        let arrayOfSearchResult = dict["items"]
        var array = Array<String?>()
        for dictionary in arrayOfSearchResult!
        {
            array.append(dictionary["link"])
        }
        delegate?.givePDFLink(link: array)
        //[self.coreDataManager save:nil];
    }
    
    // #MARK: - Help Methods
    
    func checkSearchRequest(string : String) -> Bool
    {
        let nonForbiddenSet : NSMutableCharacterSet = NSMutableCharacterSet.alphanumeric()
        nonForbiddenSet.addCharacters(in:" ")
        let isForbidden : Bool = string.rangeOfCharacter(from: nonForbiddenSet as CharacterSet) != nil || string == ""
        
        if isForbidden
        {
            return false
        }
        return true
    }
    
}
