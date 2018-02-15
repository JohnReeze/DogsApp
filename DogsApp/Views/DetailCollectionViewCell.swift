//
//  DetailCollectionViewCell.swift
//  DogsApp
//
//  Created by Mikhail Monakov on 12.02.2018.
//  Copyright © 2018 Mikhail Monakov. All rights reserved.
//

import UIKit

class DetailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var scrollView: UIScrollView!
    var imageView: UIImageView!
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
  
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.delegate = self
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        scrollView.setZoomScale(1, animated: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.contentSize = self.bounds.size
        imageView.frame = self.bounds
    }
}

// MARK: - UIScrollViewDelegate
extension DetailCollectionViewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
       return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale < 1.0 {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    // centring image in scrollView while zooming
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let subView = scrollView.subviews[0]
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * CGFloat(0.5), 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * CGFloat(0.5), 0.0)
        // adjust the center of image view
        subView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,y: scrollView.contentSize.height * 0.5 + offsetY)
    }

}
