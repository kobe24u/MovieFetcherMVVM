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
    
    var movieViewModel: MovieViewModel! {
        didSet {
            let movieImageURL = movieViewModel.imageHref
            let movieTitle = movieViewModel.title
            titleLabel.text = movieTitle
            coverImageView.sd_setImage(with: URL(string: movieImageURL)) { (image, error, cache, urls) in
                if (error != nil) {
                    //if the image address is invalid we will use a local image to show the user instead of doing nothing
                    self.coverImageView.image = UIImage(named: "NoImageFound")
                } else {
                    //Successfully downloaded the image
                    self.coverImageView.image = image
                }
            }
        }
    }
    
    override func awakeFromNib() {
        coverImageView.sd_imageIndicator = SDWebImageProgressIndicator.default
        super.awakeFromNib()
    }
}
