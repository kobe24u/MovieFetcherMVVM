//
//  MovieViewModelController.swift
//  MovieFetcherMVVM
//
//  Created by Vinnie Liu on 17/10/19.
//  Copyright © 2019 Yawei Liu. All rights reserved.
//

import Foundation

class MovieViewModelController {
    var movieViewModels: [MovieViewModel?] = []
    
    public var numberOfMovie: Int {
        return movieViewModels.count
    }
    
    //this method is used to download every single movie object's image data
    public func loadImage(at index: Int) -> DataLoadOperation? {
        if (0..<movieViewModels.count).contains(index) {
            return DataLoadOperation(movieViewModel: movieViewModels[index]!)
        }
        return .none
    }
    
    public func getMovieTitle(at index: Int) -> String{
        var title = ""
        if (0..<movieViewModels.count).contains(index) {
            title =  movieViewModels[index]!.title!
        }
        return title
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

            self.movieViewModels.removeAll()
            print("there are \(String(describing: movies?.count)) movie objects fetched")
            //we will transform the array of Movie objects to an array of MovieViewModel objects
            self.movieViewModels = movies?.map({return MovieViewModel(movie: $0)}) ?? []
            completionBlock(true, nil)
        }
    }
    
    
}
