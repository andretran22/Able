//
//  LocationViewController.swift
//  Able
//
//  Created by Tim Nguyen on 11/16/20.
//

import UIKit
import Firebase

struct City {
    let name: String
    let state: String
    let stateID: String
}

class LocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
                              UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var citiesTableView: UITableView!
    
    var delegate: UIViewController?
    var cities = [City]()
    var filteredCities = [City]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        citiesTableView.delegate = self
        citiesTableView.dataSource = self
        searchBar.delegate = self
        getCities()
    }
    
    func getCities() {
        //get all the users and put them in the userList
        let citiesRef = Database.database().reference().child("cities")
        citiesRef.observe(.value, with: {snapshot in
            for child in snapshot.children{
                if let childSnapshot = child as? DataSnapshot,
                   let cityData = childSnapshot.value as? [String:Any],
                   let city = cityData["city"] as? String,
                   let state = cityData["state_name"] as? String,
                   let stateID = cityData["state_id"] as? String {
                    
                    let city = City(name: city, state: state, stateID: stateID)
                    self.cities.append(city)
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        let city = filteredCities[indexPath.row]
        cell.textLabel?.text = "\(city.name), \(city.state)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        let createPostVC = delegate as! ChangeLocation
        let city = filteredCities[row]
        createPostVC.changeLocation(location: "\(city.name), \(city.stateID)")
        navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText.lowercased())
        filteredCities = [City]()
        for city in cities {
            if(city.name.lowercased().contains(searchText.lowercased())){
                filteredCities.append(city)
            }
        }
        citiesTableView.reloadData()
    }
    
    // This closes the keyboard when touch is detected outside of the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
