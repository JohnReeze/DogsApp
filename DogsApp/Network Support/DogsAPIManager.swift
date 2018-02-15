//
//  DogsAPI.swift
//  DogsApp
//
//  Created by Mikhail Monakov on 06.02.2018.
//  Copyright © 2018 Mikhail Monakov. All rights reserved.
//

import Foundation

enum DogNetworkError: Error, CustomStringConvertible {
    case networkError(code: Int)
    case anotherError(message: String?)

    public var description: String {
        switch self {
        case .networkError(let code):
            switch code {
            case -2000..<0:
                return "You are offline. Please check your internet connection"
            default:
                return "Network error with code \(code)"
            }
        case .anotherError(let message):
            //other cases to be handled
            return message ?? "Error"
        }
    }
}

class DogsAPIManager {
    
    let baseURL = "https://dog.ceo/api"
    let allBreedsPath = "/breeds/list"
    let breedPath = "/breed/"
    let breedImagesPath = "/images"

    static let shared = DogsAPIManager()
    
    private func getURLForBreed(breed: String) -> URL? {
        return URL(string: baseURL + breed + breedImagesPath)
    }
    
    func fetchBreeds(onSuccess: @escaping([String]) -> Void,onFailure: @escaping (DogNetworkError) -> Void) {
        guard let breedsURL = URL(string: baseURL + allBreedsPath) else { return }
        fetchDogsInfo(url: breedsURL, onSuccess: { (breeds) in
            onSuccess(breeds)
        }) { (error) in
            onFailure(error)
        }
    }
    
    func fetchURLsFor(breed: String, onSuccess: @escaping ([String]) -> Void,onFailure: @escaping (DogNetworkError) -> Void) {
        guard let breedsURL = URL(string: baseURL + breedPath + breed + breedImagesPath) else { return }
        fetchDogsInfo(url: breedsURL, onSuccess: { (breeds) in
            onSuccess(breeds)
        }) { (error) in
            onFailure(error)
        }
    }
    
    private func fetchDogsInfo(url: URL, onSuccess: @escaping ([String]) -> Void, onFailure: @escaping (DogNetworkError) -> Void) {
        
        let session = URLSession.shared
        
        session.dataTask(with: url ) { (data, response, error) in
            
            guard error == nil else {
                if let nsError = error as NSError? {
                    onFailure(DogNetworkError.networkError(code: nsError.code))
                }
                return
            }
            
            guard let data = data else {
                onFailure(DogNetworkError.anotherError(message: "No data retrieved"))
                return
            }
            
            guard let _ = response else {
                onFailure(DogNetworkError.anotherError(message: "No no response retrieved"))
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
