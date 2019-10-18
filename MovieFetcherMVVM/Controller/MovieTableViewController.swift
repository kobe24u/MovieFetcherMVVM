//
//  MovieTableViewController.swift
//  MovieFetcherMVVM
//
//  Created by Vinnie Liu on 16/10/19.
//  Copyright © 2019 Yawei Liu. All rights reserved.
//

import UIKit
import SDWebImage

class MovieTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    //here we use MovieViewModel as the bridge for communication, Controller won't talk to raw custom object any more
    var movieViewModels = [MovieViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBasicUI()
        fetchMovies()
        customizeRefreshController()
    }
    
    @objc fileprivate func fetchMovies() {
        WebServiceManager.shared.fetchMovies { (movies, err) in
            
            if let err = err {
                print("Failed to fetch movies:", err)
                return
            }
            
            //here we will do an DI and from now on, we will only talk to the MovieViewModel rather than the raw Movie class
            self.movieViewModels = movies?.map({return MovieViewModel(movie: $0)}) ?? []
            //if it's an refresh action, we shall end the refreshing
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
}

extension MovieTableViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell

        let movieViewModel = movieViewModels[indexPath.row]
        cell.movieViewModel = movieViewModel
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let imageVC  = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController{
            imageVC.movieViewModel = movieViewModels[indexPath.row]
            self.navigationController?.pushViewController(imageVC, animated: true)
        }
    }
}

//here we place all the basic tool function methods
extension MovieTableViewController{
    //added refresh controlm, when user pull and release, the tableview will refresh
    func customizeRefreshController(){
        // Add Refresh Control to Table View, when the user pull and release it will refresh the tableview
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action:  #selector(fetchMovies), for: .valueChanged)
            
            var attributes = [NSAttributedString.Key: AnyObject]()
            attributes[.foregroundColor] = UIColor.black
            //we will show the user a prompt message, when he pulls and release, the table view will refresh itself
            let attributedString = NSAttributedString(string: "Pull and release to refresh...", attributes: attributes)
            refreshControl.tintColor = UIColor.black
            refreshControl.attributedTitle = attributedString
            self.tableView.refreshControl = refreshControl
        }
    }
    
    func setupBasicUI(){
        //hide the empty rows, leave them blank
        tableView.tableFooterView = UIView(frame: .zero)
        //the prefer large nav bar title setting is only supported by ios 11.0 abovesa
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        navigationItem.title = "Movie Library"
        self.navigationController?.navigationBar.barTintColor   = UIColor(red: 204/255, green: 47/255, blue: 40/255, alpha: 1.0) // a lovely red
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func showError(_ title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
}
