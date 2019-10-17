//
//  ImageDataStore.swift
//  MovieFetcherMVVM
//
//  Created by Vinnie Liu on 16/10/19.
//  Copyright © 2019 Yawei Liu. All rights reserved.
//

import Foundation
import UIKit

//here we use NSCache to store image data to memory to avoid duplicate downloading
fileprivate let imageCache = NSCache<NSString, UIImage>()

//this helper class is used to load image
class DataLoadOperation: Operation {
    var image: UIImage?
    var loadingCompleteHandler: ((UIImage?) -> ())?
    private var movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    override func main() {
        if isCancelled { return }
        let url = movie.imageHref
        downloadImageFrom(url) { (image) in
            DispatchQueue.main.async() { [weak self] in
                guard let `self` = self else { return }
                if self.isCancelled { return }
                self.image = image
                self.loadingCompleteHandler?(self.image)
            }
        }
    }
}

//this method is used to check if we've downloaded the image before using NSCache to save data transmission cost
func downloadImageFrom(_ urlString: String, completeHandler: @escaping (UIImage?) -> ()) {
    if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
       completeHandler(imageFromCache)
    }else{
        if let url = URL(string: urlString as String) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        imageCache.setObject(image, forKey: urlString as NSString)
                        DispatchQueue.main.async {
                            completeHandler(image)
                        }
                    }
                }
            }
        }
    }
}
