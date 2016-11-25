//
//  ViewController.swift
//  MegaDownloadManager.Swift
//
//  Created by admin on 18.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UIWebViewDelegate, UISearchBarDelegate, GotPDFLinksDelegate , DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    var arrayOfDataDownload = [DataDownload]()
    var downloadManager : DownloadManager = DownloadManager.sharedManager
    var searchPDFmanager : GoogleSearchPDF = GoogleSearchPDF.sharedManager
    
    var webView : UIWebView?
    var searchBar : UISearchBar = UISearchBar()
    var searchField : UITextField?
    
    var selectedItemsArray = [DataDownload]()
    var isMultipleEditing : Bool = false
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    var reach = Reachability.init(hostName: "https://www.apple.com")
    
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
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        // A little trick for removing the cell separators
        self.tableView.tableFooterView = UIView()
    }

    func initAll() -> ()
    {
        searchPDFmanager.delegate = self
        let dataDownloadsFromDatabase : [DataDownload] = getAllDataDownloadFromaDatabase()
        self.arrayOfDataDownload.append(contentsOf: dataDownloadsFromDatabase)
    }
    func setupSearchBar() -> ()
    {
        self.searchBar.placeholder = "Type search request"
        self.searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        self.searchBar.autocapitalizationType = UITextAutocapitalizationType.none
        self.searchBar.autocorrectionType = UITextAutocorrectionType.no
        self.searchBar.spellCheckingType = UITextSpellCheckingType.no
        self.searchBar.keyboardType = UIKeyboardType.webSearch
        self.searchBar.enablesReturnKeyAutomatically = false
        self.searchBar.returnKeyType = UIReturnKeyType.search
        
        //search UITExtField in SearchBar
        let view0 = searchBar.subviews.first
        let numViews = view0?.subviews.count
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
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.tableView.allowsSelectionDuringEditing = true
    }
// MARK: - Actions
    
    @IBAction func searchAction(_ sender: UIBarButtonItem)
    {
        self.addMorePDFLinks()
        sender.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6)
        {
            sender.isEnabled = true
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        self.addMorePDFLinks()
    }
    
    @IBAction func editButtonTap(_ sender: UIBarButtonItem)
    {
        self.isMultipleEditing = !self.isMultipleEditing
        if self.isMultipleEditing
        {
            let editButton = UIBarButtonItem.init(title: "Delete All", style: .plain, target: self, action: #selector(self.editButtonTap(_:)))
            self.navigationController?.navigationBar.topItem?.leftBarButtonItem=editButton
        }
        else
        {
            let editButton = UIBarButtonItem.init(title: "Edit", style: .plain, target: self, action: #selector(self.editButtonTap(_:)))
            self.navigationController?.navigationBar.topItem?.leftBarButtonItem=editButton
            
            for cell in self.tableView.visibleCells
            {
                cell.accessoryType = .none
            }
            for dataDownloads in self.arrayOfDataDownload
            {
                dataDownloads.cellAccessoryType = .none
            }
            self.removeDataDownload(dataDownloadArray: self.selectedItemsArray)
        }
    }
// MARK: - Help Method
    func addMorePDFLinks() -> ()
    {
        if (reach?.isReachable())!
        {
            self.searchPDFmanager.getTenPDFLinksWithSearchString(searchString: self.searchBar.text!)
            self.searchBar.resignFirstResponder()
        }
        else
        {
            errorWithSearchString(string: nil)
            let alertController = UIAlertController.init(title: "No Internet Connection", message: "Your device has no internet connection now", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func reSetupCell(cell : DownloadCell) -> ()
    {
        let dataDownload : DataDownload = cell.dataDownload!
        
        cell.accessoryType = (cell.dataDownload?.cellAccessoryType)!
        
        let progress = dataDownload.progress
        let percent = self.percentFromProgress(progress: progress)
        let progressText = String.init(format: "%.2f", percent)
        
        cell.progressLabel.text = progressText
        cell.nameLabel.text = dataDownload.name
        cell.sizeProgressLabel.text = dataDownload.downloaded
        cell.progressView.setProgress(progress, animated: false)
        cell.pauseImageView.isHidden = !dataDownload.isPause
    }
    
    func percentFromProgress(progress: Float?) -> Float
    {
        if progress == nil
        {
            return 0.0
        }
        let percent = (progress!*100 < 0) || (progress!*100 > 100) ? 0.0 : progress!*100
        return percent
    }
    
    func removeDataDownload(dataDownloadArray: [DataDownload]) -> ()
    {
        for dataDownload in dataDownloadArray
        {
            if let ix = self.arrayOfDataDownload.index(of: dataDownload)
            {
                self.arrayOfDataDownload.remove(at: ix)
                
                dataDownload.removeFromDatabase()
                dataDownload.downloadTask?.cancel()
                
                dataDownload.cell?.dataDownload = nil
                dataDownload.cell = nil
            }
            
        }
        self.selectedItemsArray = [DataDownload]()
        self.tableView.reloadData()
    }
    
// MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        self.searchBar.resignFirstResponder()
    }
    
// MARK: - GotPDFLinksDelegate
    
    func givePDFLink(link: [String?])
    {
        var array = [DataDownload]()
        for urlString in link
        {
            var isHaveSomeURL = false
            for dataDownload in self.arrayOfDataDownload
            {
                isHaveSomeURL = isHaveSomeURL || dataDownload.urlString == urlString
            }
            if !isHaveSomeURL
            {
                let download = DataDownload()
                
                download.urlString = urlString
                array.append(download)
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
            
            self.arrayOfDataDownload.insert(contentsOf: array, at: 0)
            
            self.tableView.insertRows(at: arrayOfIndexs, with: UITableViewRowAnimation.automatic)
            self.tableView.reloadData()
            CoreDataManager.sharedManager.save()
        }
    }
    
    func errorWithSearchString(string: String?)
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
        let dataDownload = self.arrayOfDataDownload[indexPath.row]

        let identifier = "pdf"
        var cell : DownloadCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? DownloadCell
        
        if cell == nil
        {
            cell = DownloadCell.init(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        
        cell?.dataDownload?.cell = nil
        cell?.dataDownload = nil
        dataDownload.cell = nil
        
        cell?.dataDownload = dataDownload
        dataDownload.cell = cell
        
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
        
        if self.isMultipleEditing
        {
            let cell : DownloadCell = tableView.cellForRow(at: indexPath) as! DownloadCell
            
            if(cell.accessoryType == .none)
            {
                cell.accessoryType = .checkmark;
                cell.dataDownload?.cellAccessoryType = cell.accessoryType
                self.selectedItemsArray.append(cell.dataDownload!)
            }
            else
            {
                cell.accessoryType = .none;
                cell.dataDownload?.cellAccessoryType = cell.accessoryType
                self.selectedItemsArray = self.selectedItemsArray.filter() { $0 !== cell.dataDownload }
            }
            return
        }
        
        let dataDownload : DataDownload = self.arrayOfDataDownload[indexPath.row]
        
        if dataDownload.localURL == nil
        {
            return
        }
        let localURL = URL.init(string: dataDownload.localURL!)
        
        
        if FileManager.default.fileExists(atPath: (localURL?.relativePath)!)
        {
            self.webView?.loadHTMLString("", baseURL: nil)
            self.webView = nil
            
            let viewController = UIViewController()
            self.webView = UIWebView()
            viewController.view = self.webView
            self.webView?.delegate = self
            self.webView?.scalesPageToFit = true
            self.webView?.scrollView.minimumZoomScale = 1
            self.webView?.scrollView.maximumZoomScale = 20
            let localURLs = URL.init(string: dataDownload.localURL!)
            let pdfData = try? Data.init(contentsOf: localURLs!)

            if pdfData != nil
            {
                let cfData : CFData = pdfData as! CFData
                let pdfProvider = CGDataProvider.init(data: cfData)
                let document = CGPDFDocument.init(pdfProvider!)
                
                if document == nil
                {
                    let html = "<html><body><head><h1>Error with file</h1></head></body></html>"
                    self.webView?.loadHTMLString(html, baseURL: nil)
                }
                else
                {
                    self.webView?.load(pdfData!, mimeType: "application/pdf", textEncodingName: "UTF-8", baseURL: localURLs!)
                }
            }
            
            self.navigationController?.pushViewController(viewController, animated: true)
            
            dataDownload.isComplate = true
            dataDownload.isDownloading = false
        }
        else if !dataDownload.isDownloading
        {
            let progressBlock : ProgressBlock = {(progress: Double, identifier: Int, totalString: String) -> Void in
                dataDownload.progress = Float(progress)
                dataDownload.downloaded = totalString
            }
            let complateBlock : ComplateBlock = {(identifier: Int, url: URL) -> Void in
                dataDownload.progress = 1.0
                dataDownload.isComplate = true
                dataDownload.isDownloading = false
                let localURL = URL.init(string: dataDownload.localURL!)
                try? FileManager.default.moveItem(at: url, to: localURL!)
            }
            let errorBlock : ErrorBlock = {(error: Error) -> Void in
                dataDownload.downloaded = error.localizedDescription
                dataDownload.isDownloading = false
            }
            dataDownload.downloadTask = self.downloadManager.downloadWithURL(url: dataDownload.urlString!, progressBlock: progressBlock, complateBlock: complateBlock, errorBlock: errorBlock)
            dataDownload.identifier = dataDownload.downloadTask?.taskIdentifier
            dataDownload.isDownloading = true
        }
        else if dataDownload.isDownloading
        {
            if dataDownload.downloadTask?.state == .running
            {
                dataDownload.downloadTask?.suspend()
                dataDownload.isPause = true
            }
            else if dataDownload.downloadTask?.state == .suspended
            {
                dataDownload.downloadTask?.resume()
                dataDownload.isPause = false
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            var dataDownload : DataDownload? = self.arrayOfDataDownload[indexPath.row]
            self.arrayOfDataDownload.remove(at: indexPath.row)
            self.selectedItemsArray = self.selectedItemsArray.filter() { $0 !== dataDownload }
            
            dataDownload?.removeFromDatabase()
            dataDownload?.downloadTask?.cancel()
            
            dataDownload?.cell?.dataDownload = nil
            dataDownload?.cell = nil
            
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.tableView.endUpdates()
            
            dataDownload = nil
        }
    }
    
   
    
//MARK: - UIWebViewDelegate
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        let html = "<html><body><head><h1>Error with open</h1></head></body></html>"
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        let isExternalResource : Bool = request.url!.scheme!.hasPrefix("http")
        if  navigationType == .linkClicked && isExternalResource
        {
            return false
        }
        return true
    }
    
//MARK: - DZNEmptyDataSetSource & DZNEmptyDataSetDelegate
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString?
    {
        let str = "Please trying search something"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString?
    {
        let str = "Program trying search this in Google like pdf and u can download it and watch."
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage?
    {
        return UIImage(named: "emptyPlaceholder.png")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap view: UIView)
    {
        self.searchBar.resignFirstResponder()
    }

}

