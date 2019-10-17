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
    
    //these two lazy queue object will be used to prefetch image data for smooth scrolling without UI block
    private lazy var loadingQueue = OperationQueue()
    private lazy var loadingOperations = [IndexPath : DataLoadOperation]()
    
    //here we use MovieViewModel as the bridge for communication, Controller won't talk to raw custom object any more
    var movieViewModel = MovieViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        setupBasicUI()
        fetchMovies()
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

//added Prefetch delegate methods for smooth scrolling with lazy loading
extension MovieTableViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let _ = loadingOperations[indexPath] { return }
            //we will check if the row is visible, if yes, we will prefetch the load and get ready
            if let dataLoader = movieViewModel.loadImage(at: indexPath.row) {
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let dataLoader = loadingOperations[indexPath] {
                dataLoader.cancel()
                loadingOperations.removeValue(forKey: indexPath)
            }
        }
    }
}

extension MovieTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieViewModel.numberOfMovie
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        //we will leave the image downloading process to other delegate methods
        cell.updateAppearanceFor(.none)
        let movieTitle = movieViewModel.getMovieTitle(at: indexPath.row)
        cell.displayTitle(title: movieTitle)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

// MARK:- TableView Delegate
extension MovieTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? MovieCell else { return }
        // this operation will update the cell once the data has been loaded?
        let updateCellClosure: (UIImage?) -> () = { [unowned self] (image) in
            cell.updateAppearanceFor(image)
            self.loadingOperations.removeValue(forKey: indexPath)
        }
        
        if let dataLoader = loadingOperations[indexPath] {
            // If the data has been loaded we will update it
            if let image = dataLoader.image {
                cell.updateAppearanceFor(image)
                loadingOperations.removeValue(forKey: indexPath)
            } else {
                // No data loaded yet, so add the completion closure to update the cell once the data arrives
                dataLoader.loadingCompleteHandler = updateCellClosure
            }
        } else {
            if let dataLoader = movieViewModel.loadImage(at: indexPath.row) {
                // Provide the completion closure, and kick off the loading operation
                dataLoader.loadingCompleteHandler = updateCellClosure
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // If there's a data loader for this index path we don't need it any more. Cancel and dispose
        if let dataLoader = loadingOperations[indexPath] {
            dataLoader.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath) as? MovieCell
        if let imageVC  = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController{
            if let downloadedImage = cell?.coverImageView.image {
                //only allow navigation when the image download process is done, coz the next page does not do any HTTP request, it will show nothing there, which is not good
                let selectedIndex = indexPath.row
                imageVC.movieViewModel = movieViewModel
                imageVC.selectedIndex = selectedIndex
                imageVC.downloadedImage = downloadedImage
                self.navigationController?.pushViewController(imageVC, animated: true)
            }
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
