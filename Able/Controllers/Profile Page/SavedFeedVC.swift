//
//  SavedFeedVC.swift
//  Able
//
//  Created by Ziyi Liew on 18/11/20.
//

import UIKit
import Firebase

class SavedFeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, EditPost  {
    @IBOutlet weak var tableView: UITableView!
    var helperPosts = [Post]()
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
            viewUser = publicCurrentUser
        }
        print("CURRENTLY VIEWING THIS USER Helper Feed")
//        print(viewUser!.safeEmail)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (viewUser == nil) {
            viewUser = publicCurrentUser
        }
        fetchPosts()
    }
    
    func containsPost(posts: [Post], target: Post) -> Bool {
        for post in posts {
            if post.id == target.id {
                print("Post is already in array\n\n_________________________")
                return true
            }
        }
        
        return false
    }
    
    func fetchPosts() {
        //Database.database().reference().child(“posts”).child(“helpPosts or helperPosts”).child(postID)
        viewUser = publicCurrentUser
        let helperPostsRef = Database.database().reference().child("posts").child("helperPosts")
        let helpPostsRef = Database.database().reference().child("posts").child("helpPosts")
//        let helpPostRef = Database.database().reference().child("posts").child("helpPosts").child("troll")
        
//        print("sanity: reference is \(helpPostRef)")
        guard let posts = viewUser?.savedPosts else { return }
        var tempPosts = [Post]()
        var sanity = -1
        for uid in posts {
            print("savedPost uid: \(uid)")
            
            
            let check = Database.database().reference().child("posts").child("helpPosts").child(uid)
            
            check.observeSingleEvent(of: .value, with: { [self] snapshot in
                if let dict = snapshot.value as? [String: Any],
                let userKey = dict["userKey"] as? String,
                let authorName = dict["authorName"] as? String,
                let location = dict["location"] as? String,
                let tags = dict["tags"] as? [String],
                let text = dict["text"] as? String,
                let timestamp = dict["timestamp"] as? Double,
                let completed = dict["completed"] as? Bool {
                    print("userkey \(userKey)")
                    print("author \(authorName)")
                    print("location \(location)")
                    print("tags \(tags)")
                    print("text \(text)")
                    print("timestamp \(timestamp)")
                    print("completed \(completed)")

                    print("adding post to tempPosts")

                    var numComments = 0
                    if let anyComments = dict["comments"] as? [String: Any] {
                        numComments = anyComments.count
                    }
                    let post = Post(id: uid, userKey: userKey, authorName: authorName, location: location, tags: tags, text: text, timestamp: timestamp, numComments: numComments)
                    post.completed = completed
                    post.whichFeed = "helperPosts"
                    tempPosts.append(post)
                    if !containsPost(posts: self.helperPosts, target: post) {
                        self.helperPosts.append(post)
                    }
                }
                self.tableView.reloadData()
            })
        }

//        helperPosts = tempPosts
//        tableView.reloadData()
        
//        helperPostsRef.observe(.value, with: { snapshot in
//
//            var tempPosts = [Post]()
//
//            for child in snapshot.children {
//                if let childSnapshot = child as? DataSnapshot,
//                   let dict = childSnapshot.value as? [String: Any],
//                   let userKey = dict["userKey"] as? String,
//                   let authorName = dict["authorName"] as? String,
//                   let location = dict["location"] as? String,
//                   let tags = dict["tags"] as? [String],
//                   let text = dict["text"] as? String,
//                   let timestamp = dict["timestamp"] as? Double,
//                   let completed = dict["completed"] as? Bool {
//                    print("email is " + userKey + " viewUser safe email is " + self.viewUser!.safeEmail)
//                    if userKey == self.viewUser?.safeEmail {
//                        print("adding post to tempPosts")
//
//                        var numComments = 0
//                        if let anyComments = dict["comments"] as? [String: Any] {
//                            numComments = anyComments.count
//                        }
//                        let post = Post(id: childSnapshot.key, userKey: userKey, authorName: authorName, location: location, tags: tags, text: text, timestamp: timestamp, numComments: numComments)
//                        post.completed = completed
//                        post.whichFeed = "helperPosts"
//                        tempPosts.append(post)
//                    }
//                }
//            }
//            self.helperPosts = tempPosts
//            self.tableView.reloadData()
//        })
    }
    
    // animation to deselect cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helperPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedPostCell", for: indexPath) as! PostCell
        cell.post = helperPosts[indexPath.row]
        cell.delegate = self
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    @IBAction func nameClicked(_ sender: UIButton) {
        let postIndex = IndexPath(row: sender.tag, section: 0)
        let userKey = helperPosts[postIndex.row].userKey
        
        let usersRef = Database.database().reference()
        
        usersRef.child("users").child(userKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userData = snapshot.value as? [String:Any],
               let firstName = userData["first_name"] as? String,
               let lastName = userData["last_name"] as? String,
               let username = userData["user_name"] as? String,
               let city = userData["city"] as? String,
               let url = userData["photoURL"] as? String,
               let state = userData["state"] as? String
               {
                self.viewUser = AbleUser(firstName: firstName, lastName: lastName,
                                    emailAddress: snapshot.key, username: username, city: city, state: state, profilePicURL: url)
            }
            self.performSegue(withIdentifier: "ToProfileFromHelpFeed", sender: nil)
        })
    }
    
    func editPost(post: Post) {
        self.performSegue(withIdentifier: "ToEditPostSegueIdentifier", sender: post)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToProfileFromHelpFeed",
            let profilePageVC = segue.destination as? ProfileVC {
            profilePageVC.user = viewUser
        } else if segue.identifier == "ToEditPostSegueIdentifier",
                  let editPostVC = segue.destination as? CreatePostVC {
            let post = sender as! Post
            editPostVC.post = post
        }
    }
}