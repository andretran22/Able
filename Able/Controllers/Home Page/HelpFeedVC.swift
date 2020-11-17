//
//  HelpFeedVC.swift
//  Able
//
//  Created by Tim Nguyen on 10/16/20.
//

import UIKit
import Firebase

class HelpFeedVC: UITableViewController, EditPost {
    
    var helpPosts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchPosts()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchPosts()
    }
    
    func fetchPosts() {
        let helpPostsRef = Database.database().reference().child("posts").child("helpPosts")
        
        helpPostsRef.observe(.value, with: { snapshot in
            
            var tempPosts = [Post]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let userKey = dict["userKey"] as? String,
                   let authorName = dict["authorName"] as? String,
                   let location = dict["location"] as? String,
                   let tags = dict["tags"] as? [String],
                   let text = dict["text"] as? String,
                   let timestamp = dict["timestamp"] as? Double,
                   dict["completed"] as? Bool == false {
                    
                    var numComments = 0
                    if let anyComments = dict["comments"] as? [String: Any] {
                        numComments = anyComments.count
                    }
                    let post = Post(id: childSnapshot.key, userKey: userKey, authorName: authorName, location: location, tags: tags, text: text, timestamp: timestamp, numComments: numComments)
                    post.whichFeed = "helpPosts"
                    post.completed = false
                    tempPosts.append(post)
                }
            }
            self.helpPosts = tempPosts
            self.tableView.reloadData()
        })
    }
    
    // animation to deselect cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "ToSinglePostSegue", sender: helpPosts[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpPosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpPostCell", for: indexPath) as! PostCell
        cell.delegate = self
        cell.post = helpPosts[indexPath.row]
        cell.usernameButton.tag = indexPath.row
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    @IBAction func nameClicked(_ sender: UIButton) {
        
        let postIndex = IndexPath(row: sender.tag, section: 0)
        let userKey = helpPosts[postIndex.row].userKey
        
        let usersRef = Database.database().reference()
        
        usersRef.child("users").child(userKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userData = snapshot.value as? [String:Any],
               let firstName = userData["first_name"] as? String,
               let lastName = userData["last_name"] as? String,
               let username = userData["user_name"] as? String,
               let city = userData["city"] as? String,
               let state = userData["state"] as? String,
               let url = userData["photoURL"] as? String,
               let user_description = userData["user_description"] as? String
               {
                let viewUser = AbleUser(firstName: firstName, lastName: lastName,
                                    emailAddress: snapshot.key, username: username, city: city, state: state, profilePicURL: url, userDescription: user_description)
                self.performSegue(withIdentifier: "ToProfileFromHelpFeed", sender: viewUser)
            }
        })
    }
    
    func editPost(post: Post) {
        self.performSegue(withIdentifier: "ToSinglePostSegue", sender: post)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToProfileFromHelpFeed",
            let profilePageVC = segue.destination as? ProfileVC {
            let viewUser = sender as! AbleUser
            profilePageVC.user = viewUser
        } else if segue.identifier == "ToSinglePostSegue",
            let postVC = segue.destination as? PostViewController {
            let viewPost = sender as! Post
            postVC.post = viewPost
            postVC.whichFeed = "helpPosts"
        }
    }
}
