//
//  DownloadCellTableViewCell.swift
//  MegaDownloadManager.Swift
//
//  Created by admin on 23.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class DownloadCell: UITableViewCell
{
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeProgressLabel: UILabel!
    @IBOutlet weak var pauseImageView: UIImageView!
    
    var dataDownload : DataDownload? {
        set
        {
            self.addObserver(self, forKeyPath: "dataDownload.progress", options: NSKeyValueObservingOptions.new, context: nil)
            self.addObserver(self, forKeyPath: "dataDownload.downloaded", options: NSKeyValueObservingOptions.new, context: nil)
            self.addObserver(self, forKeyPath: "dataDownload.isComplate", options: NSKeyValueObservingOptions.new, context: nil)
            self.addObserver(self, forKeyPath: "dataDownload.isPause", options: NSKeyValueObservingOptions.new, context: nil)
        }
        get
        {
            return self.dataDownload
        }
    }
    
    override func prepareForReuse()
    {
        removeAllObserver()
    }
    
    deinit
    {
        removeAllObserver()
    }
    
    func removeAllObserver() -> ()
    {
        if self.observationInfo != nil
        {
            self.removeObserver(self, forKeyPath: "dataDownload.progress")
            self.removeObserver(self, forKeyPath: "dataDownload.downloaded")
            self.removeObserver(self, forKeyPath: "dataDownload.isComplate")
            self.removeObserver(self, forKeyPath: "dataDownload.isPause")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == "dataDownload.progress"
        {
            let progress = (change?[NSKeyValueChangeKey.newKey] as! Double)
            if progress <= -100.0
            {
                removeAllObserver()
                return
            }
            let percent = (progress*100 < 0) || (progress*100 > 100) ? 0.0 : progress*100
            DispatchQueue.main.async {
                self.progressLabel.text = String.init(format: "%.2f", percent)
                self.progressView.setProgress(Float(progress), animated: false)
            }
        }
        else if keyPath == "dataDownload.downloaded"
        {
            let text = change?[NSKeyValueChangeKey.newKey] as! String
            DispatchQueue.main.async {
                self.sizeProgressLabel.text = text
            }
        }
        else if keyPath == "dataDownload.isComplate"
        {
            if (change?[NSKeyValueChangeKey.newKey] as! Bool)
            {
                DispatchQueue.main.async {
                    self.progressLabel.text = String.init(format: "%.2f", 100.0)
                    self.progressView.setProgress(1.0, animated: false)
                }
            }
        }
        else if keyPath == "dataDownload.isPause"
        {
            let isPause = change?[NSKeyValueChangeKey.newKey] as! Bool
            DispatchQueue.main.async {
                if isPause
                {
                    self.pauseImageView.isHidden =  false
                }
                else
                {
                    self.pauseImageView.isHidden =  true
                }
            }
        }
    }
    
    
   

}
