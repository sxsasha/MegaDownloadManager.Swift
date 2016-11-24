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
    
    init()
    {
        self.arrayOfSearchHistory.addObjects(from: CoreDataManager.sharedManager.getAllSearchHistory()!)
    }
    
    func getTenPDFLinksWithSearchString(searchString: String ) -> ()
    {
        if self.checkSearchRequest(string: searchString)
        {
            self.myQueue?.async{
                self.createRequest(searchString: searchString)
            }
        }
        else
        {
            self.delegate?.errorWithSearchString(string: searchString)
        }
    }
    
    func createRequest(searchString : String) -> ()
    {
        
        var foundHistory : SearchHistory?
        for history in self.arrayOfSearchHistory as NSArray as! [SearchHistory]
        {
            if history.searchString == searchString
            {
                history.getCount = history.getCount + 10
                history.time = NSDate()
                foundHistory = history
                break
            }
        }
        if foundHistory == nil
        {
            foundHistory = CoreDataManager.sharedManager.addSearchRequest(string: searchString, count: 1, atTime: NSDate())
            self.arrayOfSearchHistory.add(foundHistory)
        }
        
        let string = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
        
        let urlString = String.init(format: "https://www.googleapis.com/customsearch/v1?q=%@&fileType=pdf&filter=1&cx=%@&key=%@&start=%d", string! ,GoogleSearchID,GoogleAPI,Int((foundHistory?.getCount)!))
        let url = URL(string: urlString)
        
        if let staticURL = url
        {
            let urlRequest = URLRequest(url: staticURL, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30.0)
            URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, urlResponse, error) in
                if data != nil
                {
                    let dictionary = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    
                    print(dictionary)
                    
                    if dictionary != nil
                    {
                        self.parseDict(dict: dictionary)//Dictionary<String, Array<Dictionary<String, String>>>) [String: [[String:String]]]
                    }
                }
            }).resume()
        }
        else
        {
            delegate?.errorWithSearchString(string: string)
        }
       
    }
    func parseDict(dict: Any) -> ()
    {
        let parseDict :NSDictionary? = dict as? NSDictionary
        let arrayOfSearchResult: [NSDictionary] = (parseDict?["items"] as! NSArray) as! [NSDictionary]
        var array = [String?]()
        for obj in arrayOfSearchResult
        {
            array.append(obj.object(forKey: "link") as! String?)
        }
        delegate?.givePDFLink(link: array)
    }
    
    // #MARK: - Help Methods
    
    func checkSearchRequest(string : String) -> Bool
    {
        let nonForbiddenSet : NSMutableCharacterSet = NSMutableCharacterSet.alphanumeric()
        nonForbiddenSet.addCharacters(in:" ")
        let forbiddenSet = nonForbiddenSet.inverted
        
        let range : Range? = string.rangeOfCharacter(from: forbiddenSet as CharacterSet) as Range?
        let isForbidden : Bool = range != nil || string == ""
        
        if isForbidden
        {
            return false
        }
        return true
    }
    
}
