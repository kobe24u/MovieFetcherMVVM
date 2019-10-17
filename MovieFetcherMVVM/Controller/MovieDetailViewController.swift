//
//  MovieDetailViewController.swift
//  MovieFetcherMVVM
//
//  Created by Vinnie Liu on 17/10/19.
//  Copyright © 2019 Yawei Liu. All rights reserved.
//

import UIKit
import Cosmos

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var starRatingView: CosmosView!
    @IBOutlet weak var releaseDate: UILabel!
    
    var movieViewModel: MovieViewModel?
    var selectedIndex: Int!
    var downloadedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Movie Details"
        
        if let selectedImage = movieViewModel?.movies[selectedIndex] {
            DispatchQueue.main.async {
                self.coverImageView.image = self.downloadedImage
                self.movieTitle.text = selectedImage.title
                self.releaseDate.text = selectedImage.releaseDate
                let movieRating = selectedImage.rating
                if movieRating == Double(0){
                    self.starRatingView.text = "no rating"
                }else{
                    self.starRatingView.rating = movieRating
                    self.starRatingView.text = "\(movieRating)/10"
                }
            }
        }
    }

}
