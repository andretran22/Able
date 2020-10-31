//
//  SearchUsersViewController.swift
//  Able
//
//  Created by Tim Nguyen on 10/30/20.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView?
    
    var user: User! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
//        nameLabel.text = user.name
//        usernameLabel.text = user.username
//        profileImageView.image = user.profileImage
    }
}

class SearchUsersViewController: UIViewController {
    
    var ref: DatabaseReference!
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
//        getUsersFromDatabase()
        print("showing users")
        // Do any additional setup after loading the view.
    }
    
//    func getUsersFromDatabase() {
//        ref = Database.database().reference()
//        let email = "app"
//    }
    
}
