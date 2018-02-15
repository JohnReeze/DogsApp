//
//  ImageViewController.swift
//  DogsApp
//
//  Created by Mikhail Monakov on 06.02.2018.
//  Copyright © 2018 Mikhail Monakov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "DogCell"
private let segueIdentifier = "ShowDetails"
class SelectedBreedCVC: UICollectionViewController {

    // MARK: - Properties
    let spacing: CGFloat = 5.1
    let cache = NSCache<NSString, UIImage>()
    
    var breed: String = ""
    let loadQueue = OperationQueue()
    var loadOperations = [IndexPath : ImageLoadOperation]()
    var URLs: [String] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
   
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.prefetchDataSource = self
        loadInfo()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func loadInfo() {
        DogsAPIManager.shared.fetchURLsFor(breed: breed, onSuccess: { (arr) in
            self.URLs = arr
        }, onFailure: { (error) in
            self.showAlert(message: error.localizedDescription)
        })
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Network error", message: message, preferredStyle: .alert)
        let actionRepeat = UIAlertAction(title: "Repeat", style: .default, handler: { [unowned self] _ in
            self.loadInfo()
        })
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { [unowned self] _ in
            self.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(actionRepeat)
        alertController.addAction(actionCancel)
        self.present(alertController, animated: true, completion: nil)
    }

}

// MARK: - Navigation

extension SelectedBreedCVC {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath  =  self.collectionView?.indexPath(for: sender as! UICollectionViewCell)
        if segue.identifier ==  segueIdentifier {
            guard let dvc = segue.destination as? DetailBreedPhotoCVC else {
                return
            }
            dvc.title = self.title
            dvc.imagesURLs = self.URLs
            dvc.cache = self.cache
            dvc.itemsOffset = indexPath!
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == segueIdentifier {
            if let indexPath  =  self.collectionView?.indexPath(for: sender as! UICollectionViewCell) {
                if let _ = self.cache.object(forKey: URLs[indexPath.row] as NSString) {
                    return true
                }
            }
        }
        return false
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SelectedBreedCVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let lenght =  (collectionView.bounds.width -  3 * spacing) / 2.0 
        return CGSize(width: lenght, height: lenght)
    }
}

// MARK: - UICollectionViewDelegate

extension SelectedBreedCVC {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return URLs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DogCollectionViewCell
        cell.loadingIndicator.startAnimating()
        if let url = URL(string: URLs[indexPath.row]) {
            if let cachedImage = self.cache.object(forKey: URLs[indexPath.row] as NSString) {
                cell.image = cachedImage
            } else {
                cell.currentURL = url
                let loadCompletion: (UIImage) -> () = { [unowned self] (image) in
                    if cell.currentURL == url {
                        cell.image = image
                        self.cache.setObject(image, forKey: url.absoluteString as NSString)
                    }
                    self.loadOperations.removeValue(forKey: indexPath)
                }
                let loadOperation = ImageLoadOperation(imageURL: url)
                loadOperation.loadCompletion = loadCompletion
                self.loadOperations[indexPath] = loadOperation
                self.loadQueue.addOperation(loadOperation)
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewataSourcePrefetching

extension SelectedBreedCVC: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            
            if let _ = loadOperations[indexPath] {
                return
            }
            if let url = URL(string: URLs[indexPath.row]) {
                let loadOperation = ImageLoadOperation(imageURL: url)
                loadOperation.loadCompletion = { [unowned self] (image) in
                    self.loadOperations.removeValue(forKey: indexPath)
                    self.cache.setObject(image, forKey: url.absoluteString as NSString)
                }
                loadOperations[indexPath] = loadOperation
                loadQueue.addOperation(loadOperation)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let loadOperation = loadOperations[indexPath] {
                loadOperation.cancel()
                loadOperations.removeValue(forKey: indexPath)
            }
        }
    }
}
