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
    
    var movieViewModelController = MovieViewModelController()
    var selectedIndex: Int!
    var downloadedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.coverImageView.image = self.downloadedImage
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
