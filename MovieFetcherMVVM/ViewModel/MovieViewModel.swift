//
//  MovieViewModel.swift
//  MovieFetcherMVVM
//
//  Created by Vinnie Liu on 16/10/19.
//  Copyright © 2019 Yawei Liu. All rights reserved.
//

import UIKit

struct MovieViewModel {
    
    let title: String
    let imageHref: String
    let rating: Double
    let releaseDate: String
    //this text is used to display the exact the rating value beside the star rating widget
    let ratingText: String
    
    // Dependency Injection (DI)
    init(movie: Movie) {
        self.title = movie.title
        self.imageHref = movie.imageHref
        self.releaseDate = movie.releaseDate
        
        if movie.rating == Double(0){
            self.ratingText = "no rating"
            self.rating = Double(0)
        }else{
            self.rating = movie.rating
            self.ratingText = "\(movie.rating)/10"
        }
    }
}
