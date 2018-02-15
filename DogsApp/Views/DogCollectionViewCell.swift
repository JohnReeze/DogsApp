//
//  DogCollectionViewCell.swift
//  DogsApp
//
//  Created by Mikhail Monakov on 08.02.2018.
//  Copyright © 2018 Mikhail Monakov. All rights reserved.
//

import UIKit

class DogCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var currentURL: URL?

    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            loadingIndicator.stopAnimating()
        }
    }
    
    override func prepareForReuse() {
        image = nil
        currentURL = nil
    }
}
