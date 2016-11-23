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
    
    var dataDownload = DataDownload?
    

    override func prepareForReuse()
    {
        
    }
   

}
