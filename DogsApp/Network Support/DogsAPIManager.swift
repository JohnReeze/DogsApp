//
//  DogsAPI.swift
//  DogsApp
//
//  Created by Mikhail Monakov on 06.02.2018.
//  Copyright © 2018 Mikhail Monakov. All rights reserved.
//

import Foundation

class DogsAPIManager {
    
    let baseURL = "https://dog.ceo/api"
    let allBreedsPath = "/breeds/list"
    let breedPath = "/breed/"
    let breedImagesPath = "/images"

    static let shared = DogsAPIManager()
    
    private func getURLForBreed(breed: String) -> URL? {
        return URL(string: baseURL + breed + breedImagesPath)
    }
    
    func fetchBreeds(onSuccess: @escaping([String]) -> Void,onFailure: @escaping (Error) -> Void) {
        guard let breedsURL = URL(string: baseURL + allBreedsPath) else { return }
        fetchDogsInfo(url: breedsURL, onSuccess: { (breeds) in
            onSuccess(breeds)
        }) { (error) in
            onFailure(error)
        }
    }
    
    func fetchURLsFor(breed: String, onSuccess: @escaping ([String]) -> Void,onFailure: @escaping (Error) -> Void) {
        guard let breedsURL = URL(string: baseURL + breedPath + breed + breedImagesPath) else { return }
        fetchDogsInfo(url: breedsURL, onSuccess: { (breeds) in
            onSuccess(breeds)
        }) { (error) in
            onFailure(error)
        }
    }
    
    private func fetchDogsInfo(url: URL, onSuccess: @escaping ([String]) -> Void, onFailure: @escaping (Error) -> Void) {
        
        let session = URLSession.shared
        
        session.dataTask(with: url ) { (data, response, error) in
            
            guard  error == nil else {
                onFailure(error!)
                return
            }
            
            guard  let data = data, let _ = response else {
                print("no data or response")
                return
            }

            do {
                let json =  try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any]
                if let arr = json?["message"] as? [String] {
                    onSuccess(arr)
                }
            } catch let jsonError {
                print("json error : \(jsonError)")
            }
        }.resume()
    }
}
