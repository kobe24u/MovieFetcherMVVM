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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Movie Details"
        
        if let selectedImage = movieViewModel?.getMovie(at: selectedIndex) {
            DispatchQueue.main.async {
                self.coverImageView.sd_setImage(with: URL(string: selectedImage.imageHref)) { (image, error, cache, urls) in
                    if (error != nil) {
                        //Failure code here
                        self.coverImageView.image = UIImage(named: "NoImageFound")
                    } else {
                        //Success code here
                        self.coverImageView.image = image
                    }
                }
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
