//
//  SearchUsersViewController.swift
//  Able
//
//  Created by Tim Nguyen on 10/30/20.
//

import UIKit
import Firebase
import Foundation

class UserCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
}

class SearchUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userTableView: UITableView!
    var ref: DatabaseReference!
    public var filteredUserList:[AbleUser] = []
    let userCellIdentifier = "userCellIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
//        getUsersFromDatabase()
        print("showing users")
        // Do any additional setup after loading the view.
        //observe the filteredUserList
//        var observableList = filteredUserList as NSObject
        userTableView.delegate = self
        userTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUserList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userCellIdentifier, for: indexPath as IndexPath) as! UserCell
        let user = filteredUserList[indexPath.row]
        //update the cell
        cell.nameLabel.text = "\(user.firstName!) \(user.lastName!)"
        ImageService.downloadImage(withURL: URL(string: user.profilePicUrl)!) { image in
            cell.profileImageView.image = image
        }
        cell.usernameLabel.text = "@\(user.username!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //this function gets executed when you tap a row
        tableView.deselectRow(at: indexPath, animated: true)
        let user = filteredUserList[indexPath.row]
        self.performSegue(withIdentifier: "ToProfileFromSearchUser", sender: user)
    }
    
    public func updateTableView(){
        userTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToProfileFromSearchUser",
            let profilePageVC = segue.destination as? ProfileVC {
            let user = sender as! AbleUser
            profilePageVC.user = user
        }
    }
    
}
