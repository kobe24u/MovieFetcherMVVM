//
//  MovieCell.swift
//  MovieFetcherMVVM
//
//  Created by Vinnie Liu on 16/10/19.
//  Copyright © 2019 Yawei Liu. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with movieViewModel: MovieViewModel?) {
        guard let movieViewModel = movieViewModel else { return }
        titleLabel?.text = movieViewModel.title
        if let coverImageUrl = movieViewModel.imageHref {
            coverImageView.loadImage(urlString:coverImageUrl)
        } else {
            coverImageView.showUnavailableImage()
        }
    }
}
