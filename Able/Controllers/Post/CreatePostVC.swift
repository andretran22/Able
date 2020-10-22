//
//  CreatePostVC.swift
//  Able
//
//  Created by Tim Nguyen on 10/14/20.
//

import UIKit
import Firebase

class CreatePostVC: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var segCtrlFeed: UISegmentedControl!
    @IBOutlet weak var postTextField: UITextField!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        displayInfo(uid: uid)
    }
    
    // when clicked, check for segCtrlFeed and
    @IBAction func postButtonClicked(_ sender: Any) {
        let currentUser = User(username: nameLabel.text, profileImage: UIImage(named: "default"))
        
        let newPost = Post(createdBy: currentUser, timeAgo: "Just now", caption: postTextField.text, image: UIImage(named: "1"), numberOfComments: 0)
        
        if (segCtrlFeed.selectedSegmentIndex == 0) {
            Post.addHelpPost(post: newPost)
        } else {
            Post.addHelperPost(post: newPost)
        }
    }
    
    // get user data from Firebase realtime Database and display on screen
    // TODO: implement displaying other people's profiles
    func displayInfo(uid: String) {
        ref = Database.database().reference()
       
        ref.child("user").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let getData = snapshot.value as? [String:Any] {
                let name = getData["name"] as? String
                let city = getData["city"] as? String
                let state = getData["state"] as? String
                self.nameLabel.text = name
                self.locationLabel.text = "\(city ?? ""), \(state ?? "")"
            }
          }) { (error) in
            print(error.localizedDescription)
        }
    }
}
