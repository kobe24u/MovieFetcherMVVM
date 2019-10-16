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
    //added a loading spinner for better UX
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateAppearanceFor(_ image: UIImage?, movieViewModel: MovieViewModel) {
        DispatchQueue.main.async { [unowned self] in
            self.displayImage(image)
            self.titleLabel.text = movieViewModel.title
        }
    }
    
    //we won't download the image when it's not visible
    private func displayImage(_ image: UIImage?) {
        if let _image = image {
            coverImageView.image = _image
            loadingSpinner.stopAnimating()
        } else {
            loadingSpinner.startAnimating()
            coverImageView.image = .none
        }
    }
}
