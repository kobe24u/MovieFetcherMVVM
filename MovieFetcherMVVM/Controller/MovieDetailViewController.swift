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
    
    var selectedMovieViewModel: MovieViewModel?
    var downloadedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.coverImageView.image = self.downloadedImage
            self.movieTitle.text = self.selectedMovieViewModel?.title
            self.releaseDate.text = self.selectedMovieViewModel?.releaseDate
            let movieRating = self.selectedMovieViewModel?.rating ?? Double(0)
            if movieRating == Double(0){
                self.starRatingView.text = "no rating"
            }else{
                self.starRatingView.rating = movieRating
                self.starRatingView.text = "\(movieRating)/10"
            }
        }
        navigationItem.title = "Movie Details"
    }

}
