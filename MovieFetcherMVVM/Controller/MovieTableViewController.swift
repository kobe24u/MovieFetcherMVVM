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
    var movieViewModel = MovieViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBasicUI()
        fetchMovies()
        tableView.estimatedRowHeight = 200
        
        tableView.rowHeight = UITableView.automaticDimension
        customizeRefreshController()
    }
    
    @objc private func fetchMovies() {
        //activityIndicator.startAnimating()
        self.movieViewModel.retrieveMovies { (success, error) in
            if !success {
                DispatchQueue.main.async {
                    let title = "Error"
                    if let error = error {
                        self.showError(title, message: error.localizedDescription)
                    } else {
                        self.showError(title, message: NSLocalizedString("Can't retrieve contacts.", comment: "The message displayed when contacts can’t be retrieved."))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension MovieTableViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieViewModel.numberOfMovie
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        //we will leave the image downloading process to other delegate methods
        let movieImageURL = movieViewModel.getMovie(at: indexPath.row).imageHref
        let movieTitle = movieViewModel.getMovie(at: indexPath.row).title
        cell.coverImageView.sd_setImage(with: URL(string: movieImageURL)) { (image, error, cache, urls) in
            if (error != nil) {
                //Failure code here
                cell.coverImageView.image = UIImage(named: "NoImageFound")
            } else {
                //Success code here
                cell.coverImageView.image = image
            }
        }
        cell.displayTitle(title: movieTitle)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let imageVC  = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController{
            let selectedIndex = indexPath.row
            imageVC.movieViewModel = movieViewModel
            imageVC.selectedIndex = selectedIndex
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
