//
//  ReviewTableViewVC.swift
//  Able
//
//  Created by Ziyi Liew on 3/11/20.
//

import UIKit
import Firebase

class ReviewTableViewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var reviews = [Post]()
    var postIndex: IndexPath?
    var viewUser: AbleUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchPosts()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        if (viewUser == nil) {
            print("this should not happen, passed in user should not be nil (ReviewTableViewVC)")
            viewUser = publicCurrentUser
        }
        print("CURRENTLY VIEWING THIS USER Review Feed")
        print(viewUser!.safeEmail)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchPosts()
    }
    
    func fetchPosts() {
        print("executing fetchPosts in reviews")
        let reviewsRef = Database.database().reference().child("users").child(viewUser!.safeEmail).child("reviews")
        
        reviewsRef.observe(.value, with: { snapshot in
            
            var tempPosts = [Post]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let userKey = dict["userKey"] as? String,
                   let authorName = dict["authorName"] as? String,
                   let location = dict["location"] as? String,
                   let text = dict["text"] as? String,
                   let rating = dict["rating"] as? Double,
                   let timestamp = dict["timestamp"] as? Double {

                    let post = Post(id: childSnapshot.key, userKey: userKey, authorName: authorName, location: location, text: text, timestamp: timestamp, rating: rating)
                    
                    tempPosts.append(post)
                
                }
            }
            self.reviews = tempPosts
            self.tableView.reloadData()
        })
    }
    
    // animation to deselect cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewPost", for: indexPath) as! PostCell
        cell.post = reviews[indexPath.row]
        cell.usernameButton.tag = indexPath.row
        cell.postStatsLabel.text = String(Int(reviews[indexPath.row].rating!))
        // add shadow on cell
        cell.backgroundColor = .clear // very important
        cell.layer.masksToBounds = false
        cell.layer.shadowOpacity = 0.23
        cell.layer.shadowRadius = 3
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowColor = UIColor.black.cgColor

        // add corner radius on `contentView`
        cell.contentView.backgroundColor = .white
        cell.contentView.layer.cornerRadius = 8
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    @IBAction func nameClicked(_ sender: UIButton) {
        postIndex = IndexPath(row: sender.tag, section: 0)
        let userKey = reviews[postIndex!.row].userKey
        
        let usersRef = Database.database().reference()
        
        usersRef.child("users").child(userKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userData = snapshot.value as? [String:Any],
               let firstName = userData["first_name"] as? String,
               let lastName = userData["last_name"] as? String,
               let username = userData["user_name"] as? String,
               let city = userData["city"] as? String,
               let state = userData["state"] as? String
               {
                self.viewUser = AbleUser(firstName: firstName, lastName: lastName,
                                    emailAddress: snapshot.key, username: username, city: city, state: state)
            }
            self.performSegue(withIdentifier: "ToProfileFromHelpFeed", sender: nil)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToProfileFromHelpFeed",
            let profilePageVC = segue.destination as? ProfileVC {
            profilePageVC.user = viewUser
        }
    }
}
