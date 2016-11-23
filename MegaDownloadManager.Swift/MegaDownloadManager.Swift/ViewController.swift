//
//  ViewController.swift
//  MegaDownloadManager.Swift
//
//  Created by admin on 18.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UIWebViewDelegate, UISearchBarDelegate, UITableViewDataSource,UITableViewDelegate, GotPDFLinksDelegate //, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    var arrayOfDataDownload = NSMutableArray()
    var downloadManager : DownloadManager = DownloadManager.sharedManager
    var searchPDFmanager : GoogleSearchPDF = GoogleSearchPDF.sharedManager
    
    var webView : UIWebView?
    var searchBar : UISearchBar = UISearchBar()
    var searchField : UITextField?
    
//    @property (nonatomic,strong) NSMutableArray* arrayOfDataDownload;
//    @property (nonatomic,strong) Reachability* reach;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.emptyTableView()
        self.initAll()
        self.setupSearchBar()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
// MARK: - Init function
    
    func emptyTableView() -> ()
    {
        // For EmptyDataSet
        // empty tableView
        //    self.tableView.emptyDataSetSource = self;
        //    self.tableView.emptyDataSetDelegate = self;
        
        // A little trick for removing the cell separators
        self.tableView.tableFooterView = UIView()
    }

    func initAll() -> ()
    {
        searchPDFmanager.delegate = self
        let dataDownloadsFromDatabase : [DataDownload] = getAllDataDownloadFromaDatabase()
        self.arrayOfDataDownload.addObjects(from: dataDownloadsFromDatabase)
        
        // check if we have internet connections with Reachability
        //self.reach = [Reachability reachabilityWithHostname:@"https://www.apple.com"];
    }
    func setupSearchBar() -> ()
    {
        searchBar.placeholder = "Type search request"
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchBar.autocapitalizationType = UITextAutocapitalizationType.none
        searchBar.autocorrectionType = UITextAutocorrectionType.no
        searchBar.spellCheckingType = UITextSpellCheckingType.no
        searchBar.keyboardType = UIKeyboardType.webSearch
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.returnKeyType = UIReturnKeyType.search
        
        let view0 = searchBar.subviews.first
        let numViews = view?.subviews.count
        var i : Int = 0
        
        while i < numViews!
        {
            if (view0?.subviews[i].isKind(of: UITextField.self))!
            {
                self.searchField = view0?.subviews[i] as? UITextField
            }
            i = i + 1
        }

    }
// MARK: - Actions
    
    @IBAction func searchAction(_ sender: UIBarButtonItem)
    {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        
    }
    
// MARK: - Help Method
    func addMorePDFLinks() -> ()
    {
        if true
        {
            self.searchPDFmanager.getTenPDFLinksWithSearchString(searchString: self.searchBar.text!)
        }
        else
        {
            //[self errorWithSearchString:nil];
            let alertController = UIAlertController.init(title: "No Internet Connection", message: "Your device has no internet connection now", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func reSetupCell(cell : DownloadCell) -> ()
    {
        cell.dataDownload?.progress = cell.dataDownload?.progress
        let progress = cell.dataDownload?.progress
        let percent = self.percentFromProgress(progress: progress!)
        cell.progressLabel.text = String.init(format: "%.2f", percent)
        cell.nameLabel.text = cell.dataDownload?.name
        cell.sizeProgressLabel.text = cell.dataDownload?.downloaded
        cell.progressView.setProgress(progress!, animated: false)
        cell.pauseImageView.isHidden = !(cell.dataDownload?.isPause)!
        
        
    }
    
    func percentFromProgress(progress: Float) -> Float
    {
        let percent = (progress*100 < 0) || (progress*100 > 100) ? 0.0 : progress*100
        return percent
    }
    
// MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        self.searchBar.resignFirstResponder()
    }
    
// MARK: - GotPDFLinksDelegate
    func givePDFLink(link: [String?])
    {
        let array = NSMutableArray()
        for urlString in link
        {
            var isHaveSomeURL = false
            for dataDownload in self.arrayOfDataDownload
            {
                isHaveSomeURL = isHaveSomeURL || (dataDownload as! DataDownload).urlString == urlString
            }
            if !isHaveSomeURL
            {
                let download = DataDownload()
                download.urlString = urlString
                array.add(download)
            }
        }
        DispatchQueue.main.async {
            var arrayOfIndexs = [IndexPath]()
            
            var i : Int = 0
            while i < array.count
            {
                let indexPath = IndexPath.init(row: i, section: 0)
                arrayOfIndexs.append(indexPath)
                i = i + 1
            }
            let indexSet = IndexSet.init(integersIn: 0...array.count)
            self.arrayOfDataDownload.insert(array as NSArray as! [Any], at: indexSet)
            self.tableView.insertRows(at: arrayOfIndexs, with: UITableViewRowAnimation.automatic)
            self.tableView.reloadData()
            CoreDataManager.sharedManager.save()
        }
    }
    
    func errorWithSearchString(string : String) -> ()
    {
        UIView.animate(withDuration: 0.3, animations: { 
            self.searchField?.backgroundColor = UIColor.red
            }) { (finished) in
                self.searchField?.backgroundColor = nil
        }
    }
    
// MARK: - UITableViewDataSource & UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.arrayOfDataDownload.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let identifier = "pdf"
        
        var cell : DownloadCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? DownloadCell
        
        if cell == nil
        {
            cell = DownloadCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        
        cell?.dataDownload = self.arrayOfDataDownload.object(at: indexPath.row) as? DataDownload
        
        reSetupCell(cell: cell!)
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var dataDownload : DataDownload = (self.arrayOfDataDownload.object(at: indexPath.row) as? DataDownload)!
        
        let localURL = URL.init(string: dataDownload.localURL!)
        
        
        if FileManager.default.fileExists(atPath: (localURL?.relativePath)!)
        {
            
        }
        
        
    }
    

}

