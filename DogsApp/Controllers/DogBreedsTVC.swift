//
//  DogBreedsTBC.swift
//  DogsApp
//
//  Created by Mikhail Monakov on 06.02.2018.
//  Copyright © 2018 Mikhail Monakov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "BreedNameCell"
private let segueIdentifier = "ShowDogPhotos"

class DogBreedsTVC: UITableViewController {

    // MARK: - Properties
    private var breeds : [String] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInfo()
    }
    
    func loadInfo() {
        DogsAPIManager.shared.fetchBreeds(onSuccess: { [unowned self] (result) in
            self.breeds = result
        }) { [unowned self] (error) in
            self.showAlert(message: error.description)
        }
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Network error", message: message, preferredStyle: .alert)
        let actionRepeat = UIAlertAction(title: "Repeat", style: .default, handler: { [unowned self] _ in
            self.loadInfo()
        })
        alertController.addAction(actionRepeat)
        self.present(alertController, animated: true, completion: nil)
    }
}


//MARK: - UINavigation

extension DogBreedsTVC {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath  =  self.tableView.indexPath(for: sender as! UITableViewCell)!
        if segue.identifier ==  segueIdentifier {
            guard let ivc = segue.destination as? SelectedBreedCVC else {
                return
            }
            ivc.breed = breeds[indexPath.row]
            ivc.title = breeds[indexPath.row]
        }
    }
}

//MARK: - UITableViewDataSourse

extension DogBreedsTVC {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breeds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = breeds[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = cellData
        return cell
    }
}

