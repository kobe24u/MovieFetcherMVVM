//
//  MovieViewModel.swift
//  MovieFetcherMVVM
//
//  Created by Vinnie Liu on 16/10/19.
//  Copyright © 2019 Yawei Liu. All rights reserved.
//

import UIKit

class MovieViewModel {
    
    var movies: [Movie?] = []
    
    public var numberOfMovie: Int {
        return movies.count
    }
    
    public func getMovie(at index: Int) -> Movie{
        var movie = Movie(title: "sample title", imageHref: "https://1080motion.com/wp-content/uploads/2018/06/NoImageFound.jpg.png", rating: Double(0), releaseDate: "")
        if (0..<movies.count).contains(index) {
            movie =  movies[index]!
        }
        return movie
    }
    
    //here we will take advantage of WebServiceManager and make an API call to fetch the movie data
    //here we use completion handler, so no further action will be done until it's completed
    func retrieveMovies(_ completionBlock: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        
        WebServiceManager.shared.fetchMovies { (movies, err) in

            if let err = err {
                print("Failed to fetch movie data:", err)
                completionBlock(false, err)
                return
            }

            self.movies.removeAll()
            print("there are \(String(describing: movies?.count)) movie objects fetched")
            //we will transform the array of Movie objects to an array of MovieViewModel objects
            self.movies = movies ?? []
            completionBlock(true, nil)
        }
    }
}
