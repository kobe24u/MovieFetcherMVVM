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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Movie Details"
        showMovieDetails()
    }
    
    func showMovieDetails(){
        DispatchQueue.main.async {
            self.coverImageView.sd_setImage(with: URL(string: self.movieViewModel?.imageHref ?? "https://1080motion.com/wp-content/uploads/2018/06/NoImageFound.jpg.png")) { (image, error, cache, urls) in
                if (error != nil) {
                    //Failure code here
                    self.coverImageView.image = UIImage(named: "NoImageFound")
                } else {
                    //Success code here
                    self.coverImageView.image = image
                }
            }
            self.movieTitle.text = self.movieViewModel?.title
            self.releaseDate.text = self.movieViewModel?.releaseDate
            self.starRatingView.rating = self.movieViewModel?.rating ?? Double(0)
            self.starRatingView.text = self.movieViewModel?.ratingText
        }
    }

}
