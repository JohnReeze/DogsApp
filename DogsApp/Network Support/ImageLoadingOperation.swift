//
//  ImageLoadingOperation.swift
//  DogsApp
//
//  Created by Mikhail Monakov on 09.02.2018.
//  Copyright © 2018 Mikhail Monakov. All rights reserved.
//

import UIKit

class ImageLoadOperation: Operation {
    
    var imageURL: URL
    var loadCompletion: ( (UIImage) -> Void )?
    
    init(imageURL url: URL) {
        imageURL = url
    }
    
    override func main() {
        
        if isCancelled { return }
    
        let imageData = NSData(contentsOf: imageURL)
    
        DispatchQueue.main.async {
            if let data = imageData as Data? {
                if let image = UIImage(data: data), let completion = self.loadCompletion {
                    completion(image)
                }
            }
        }
    }
}
