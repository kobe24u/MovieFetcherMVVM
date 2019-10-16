//
//  MovieViewModel.swift
//  MovieFetcherMVVM
//
//  Created by Vinnie Liu on 16/10/19.
//  Copyright © 2019 Yawei Liu. All rights reserved.
//

import UIKit

struct MovieViewModel {
    
    let title: String?
    let releaseDate: String?
    let rating: Double?
    let imageHref: String?
    
    // Dependency Injection
    init(movie: Movie) {
        releaseDate = movie.releaseDate
        title = movie.title
        rating = movie.rating
        imageHref = movie.imageHref
    }
}
