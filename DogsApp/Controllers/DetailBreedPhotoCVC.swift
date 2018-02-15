//
//  DetailBreedPhotoCVC.swift
//  DogsApp
//
//  Created by Mikhail Monakov on 12.02.2018.
//  Copyright © 2018 Mikhail Monakov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "BreedImageCell"

class DetailBreedPhotoCVC: UICollectionViewController {
    
    // MARK: - Properties
    var imagesURLs: [String] = []
    var cache: NSCache<NSString, UIImage>?

    var itemsOffset: IndexPath = IndexPath() {
        didSet {
            collectionView?.scrollToItem(at: itemsOffset, at: .left, animated: false)
            imagesURLs = imagesURLs.filter({ (url) -> Bool in
                if let _ = cache?.object(forKey: url as NSString) {
                    return true
                }
                return false
            })
            collectionView?.reloadData()
        }
    }

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    // rotation case
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //this centers images while rotating
        let offset = collectionView!.contentOffset
        let width = collectionView!.bounds.size.width
        let index = round(offset.x / width)
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        collectionView?.setContentOffset(newOffset, animated: false)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - UICollectionViewDataSource
extension DetailBreedPhotoCVC {
 
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesURLs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DetailCollectionViewCell
        
        if let image = cache?.object(forKey: imagesURLs[indexPath.row] as NSString) {
            cell.image = image
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DetailBreedPhotoCVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width , height: collectionView.bounds.height)
    }
}
