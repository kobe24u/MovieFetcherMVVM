//
//  MovieCell.swift
//  MovieFetcherMVVM
//
//  Created by Vinnie Liu on 16/10/19.
//  Copyright © 2019 Yawei Liu. All rights reserved.
//

import UIKit
import SDWebImage

class MovieCell: UITableViewCell {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        coverImageView.sd_imageIndicator = SDWebImageProgressIndicator.default
        super.awakeFromNib()
    }
    
    func displayTitle(title: String){
        DispatchQueue.main.async {
            self.titleLabel.text = title
        }
    }
}
