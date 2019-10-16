//
//  MovieTableViewController.swift
//  MovieFetcherMVVM
//
//  Created by Vinnie Liu on 16/10/19.
//  Copyright © 2019 Yawei Liu. All rights reserved.
//

import UIKit

class MovieTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var totalCount = 0
    
    var movieViewModels: [MovieViewModel] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide the empty rows, leave them blank
        tableView.tableFooterView = UIView(frame: .zero)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Movie Library"
        fetchMovies()
    }
    
    private func fetchMovies() {

        activityIndicator.startAnimating()
        
        WebServiceManager.shared.fetchMovies { [weak self] (movies, err) in
            if let err = err {
                print("Failed to fetch movie data:", err)
                return
            }
            guard let weakSelf = self else { return }
            
            print("there are \(String(describing: movies?.count)) movie objects fetched")
            
            if let movies = movies{
                DispatchQueue.main.async {
                    weakSelf.activityIndicator.stopAnimating()
                    weakSelf.totalCount = movies.count
                    weakSelf.movieViewModels.append(contentsOf: movies.map({ return MovieViewModel(movie: $0)}))
                }
            }
        }
        
    }
}

extension MovieTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        cell.configure(with: movieViewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
