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
    
    //these two lazy queue object will be used to prefetch image data for smooth scrolling without UI block
    private lazy var loadingQueue = OperationQueue()
    private lazy var loadingOperations = [IndexPath : DataLoadOperation]()
    
    var movieViewModels = [MovieViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        setupBasicUI()
        fetchMovies()
        customizeRefreshController()
    }

    //added refresh controlm, when user pull and release, the tableview will refresh
    func customizeRefreshController(){
        // Add Refresh Control to Table View, when the user pull and release it will refresh the tableview
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action:  #selector(fetchMovies), for: .valueChanged)
            
            // Green color
            let greenColor = UIColor(red: 10/255, green: 190/255, blue: 50/255, alpha: 1.0)
            var attributes = [NSAttributedString.Key: AnyObject]()
            attributes[.foregroundColor] = greenColor
            //we will show the user a prompt message, when he pulls and release, the table view will refresh itself
            let attributedString = NSAttributedString(string: "Pull and release to refresh...", attributes: attributes)
            refreshControl.tintColor = greenColor
            refreshControl.attributedTitle = attributedString
            self.tableView.refreshControl = refreshControl
        }
    }
    
    func setupBasicUI(){
        //hide the empty rows, leave them blank
        tableView.tableFooterView = UIView(frame: .zero)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Movie Library"
    }
    
    @objc private func fetchMovies() {
        activityIndicator.startAnimating()
        WebServiceManager.shared.fetchMovies { [weak self] (movies, err) in
            
            self?.movieViewModels.removeAll()
            guard let weakSelf = self else { return }
            
            if let err = err {
                print("Failed to fetch movie data:", err)
                weakSelf.tableView.refreshControl?.endRefreshing()
                return
            }
            
            print("there are \(String(describing: movies?.count)) movie objects fetched")
            
            if let movies = movies{
                DispatchQueue.main.async {
                    weakSelf.activityIndicator.stopAnimating()
                    weakSelf.totalCount = movies.count
                    weakSelf.movieViewModels.append(contentsOf: movies.map({ return MovieViewModel(movie: $0)}))
                    weakSelf.tableView.refreshControl?.endRefreshing()
                    weakSelf.tableView.reloadData()
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
            if (0..<self.movieViewModels.count).contains(indexPath.row){
                let dataLoader = DataLoadOperation(movieViewModel: self.movieViewModels[indexPath.row])
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
        return totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movieViewModel = self.movieViewModels[indexPath.row]
        //we will leave the image downloading process to other delegate methods
        cell.updateAppearanceFor(.none, movieViewModel: movieViewModel)
        return cell
    }
    
}

// MARK:- TableView Delegate
extension MovieTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? MovieCell else { return }
        let movieViewModel = self.movieViewModels[indexPath.row]
        
        // this operation will update the cell once the data has been loaded?
        let updateCellClosure: (UIImage?) -> () = { [unowned self] (image) in
            cell.updateAppearanceFor(image, movieViewModel: movieViewModel)
            self.loadingOperations.removeValue(forKey: indexPath)
        }
        
        if let dataLoader = loadingOperations[indexPath] {
            // If the data has been loaded we will update it
            if let image = dataLoader.image {
                cell.updateAppearanceFor(image, movieViewModel: movieViewModel)
                loadingOperations.removeValue(forKey: indexPath)
            } else {
                // No data loaded yet, so add the completion closure to update the cell once the data arrives
                dataLoader.loadingCompleteHandler = updateCellClosure
            }
        } else {
            if (0..<self.movieViewModels.count).contains(indexPath.row){
                let dataLoader = DataLoadOperation(movieViewModel: self.movieViewModels[indexPath.row])
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
}
