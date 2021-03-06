//
//  SavedFeedVC.swift
//  Able
//
//  Created by Ziyi Liew on 18/11/20.
//

import UIKit
import Firebase

class SavedFeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource,
                   EditPost, DeletePost, UnsavePost  {
    @IBOutlet weak var tableView: UITableView!
    var savedPosts = [Post]()
    var viewUser: AbleUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchPosts()
        tableView.delegate = self
        tableView.dataSource = self
        
        if (viewUser == nil) {
            viewUser = publicCurrentUser
        }
        print("CURRENTLY VIEWING THIS USER Saved Feed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        savedPosts = [Post]()
        fetchPosts()
    }
    
    // check if a post is present in the list of posts
    func containsPost(posts: [Post], target: Post) -> Bool {
        for post in posts {
            if post.id == target.id {
                return true
            }
        }
        
        return false
    }
    
    // fetch the saved posts from firebase database
    func fetchPosts() {
        viewUser = publicCurrentUser

        guard let posts = viewUser?.savedPosts else { return }
        var tempPosts = [Post]()
        for uid in posts {
            print("savedPost uid: \(uid)")
            
            
            let help = Database.database().reference().child("posts").child("helpPosts").child(uid)
            let helper = Database.database().reference().child("posts").child("helperPosts").child(uid)
            
            help.observeSingleEvent(of: .value, with: { [self] snapshot in
                if let dict = snapshot.value as? [String: Any],
                let userKey = dict["userKey"] as? String,
                let authorName = dict["authorName"] as? String,
                let location = dict["location"] as? String,
                let tags = dict["tags"] as? [String],
                let text = dict["text"] as? String,
                let timestamp = dict["timestamp"] as? Double,
                let completed = dict["completed"] as? Bool {
                    print("adding help post to savedPosts")

                    var numComments = 0
                    if let anyComments = dict["comments"] as? [String: Any] {
                        numComments = anyComments.count
                    }
                    let post = Post(id: uid, userKey: userKey, authorName: authorName, location: location, tags: tags, text: text, timestamp: timestamp, numComments: numComments)
                    post.completed = completed
                    post.whichFeed = "helpPosts"
                    if let imageURL = dict["image"] as? String {
                        post.image = imageURL
                    }
                    tempPosts.append(post)
                    if !containsPost(posts: self.savedPosts, target: post) {
                        self.savedPosts.append(post)
                    }
                }
                self.tableView.reloadWithAnimation()
            })
            
            helper.observeSingleEvent(of: .value, with: { [self] snapshot in
                if let dict = snapshot.value as? [String: Any],
                let userKey = dict["userKey"] as? String,
                let authorName = dict["authorName"] as? String,
                let location = dict["location"] as? String,
                let tags = dict["tags"] as? [String],
                let text = dict["text"] as? String,
                let timestamp = dict["timestamp"] as? Double,
                let completed = dict["completed"] as? Bool {
                    print("adding helper post to savedPosts")

                    var numComments = 0
                    if let anyComments = dict["comments"] as? [String: Any] {
                        numComments = anyComments.count
                    }
                    let post = Post(id: uid, userKey: userKey, authorName: authorName, location: location, tags: tags, text: text, timestamp: timestamp, numComments: numComments)
                    post.completed = completed
                    post.whichFeed = "helperPosts"
                    if let imageURL = dict["image"] as? String {
                        post.image = imageURL
                    }
                    tempPosts.append(post)
                    if !containsPost(posts: self.savedPosts, target: post) {
                        self.savedPosts.append(post)
                    }
                }
                self.tableView.reloadWithAnimation()
            })
        }
    }
    
    // animation to deselect cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "ToSinglePostSegue", sender: savedPosts[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = savedPosts[indexPath.row]
        var whichPostCell = "SavedPostCell"
        if post.image != nil {
            whichPostCell = "SavedPostCellWithImage"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: whichPostCell, for: indexPath) as! PostCell
        cell.post = post
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = savedPosts[indexPath.row]
        if (post.image != nil) {
            return 320
        }
        return 220
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
    }
    
    @IBAction func nameClicked(_ sender: UIButton) {
        let postIndex = IndexPath(row: sender.tag, section: 0)
        let userKey = savedPosts[postIndex.row].userKey
        
        // don't go to your own profile if you're already on your own profile
        if (publicCurrentUser?.safeEmail != userKey) {
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
                self.performSegue(withIdentifier: "ToProfileFromSavedFeed", sender: nil)
            })
        }
    }
    
    func editPost(post: Post) {
        self.performSegue(withIdentifier: "ToEditPostSegueIdentifier", sender: post)
    }
    
    func deletePost(post: Post) {
        let controller = UIAlertController(title: "Post Deletion",
                                           message: "Are you sure you want to delete this post?",
                                           preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Cancel",
                                           style: .cancel,
                                           handler: nil))
        
        controller.addAction(UIAlertAction(title: "Delete",
                                           style: .destructive,
                                           handler: { (action) in
                                            print("DELETING THE POST WITH ID: \(post.id)")
                                            
                                            let ref = Database.database().reference()
                                            // NEED TO POP UP AN ALERT TO CONFIRM DELETION
                                            // Remove the post from the DB
                                            ref.child("posts").child(post.whichFeed!).child(post.id).removeValue { error, ref in
                                                if error != nil {
                                                    print("error \(String(describing: error))")
                                                } else {
                                                    if post.image != nil {
                                                        // Create a reference to the file to delete
                                                        let imageRef = Storage.storage().reference().child("posts/\(post.whichFeed!)/\(post.id)")

                                                        // Delete the file
                                                        imageRef.delete { error in
                                                          if let error = error {
                                                            print("error \(error)")
                                                            // Uh-oh, an error occurred!
                                                          } else {
                                                            // File deleted successfully
                                                          }
                                                        }
                                                    }
                                                    print("\(post.id) IS DELETED")
                                                    if let index = self.savedPosts.firstIndex(of: post) {
                                                        self.savedPosts.remove(at: index)
                                                        self.tableView.reloadWithAnimation()
                                                    }
                                                }
                                            }
                                           }))
        
        present(controller, animated: true, completion: nil)
    }
    
    // remove the post from saved posts and reload the table view
    func unsavePost(post: Post) {
        if let index = savedPosts.firstIndex(of: post) {
            savedPosts.remove(at: index)
            tableView.reloadWithAnimation()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToProfileFromSavedFeed",
            let profilePageVC = segue.destination as? ProfileVC {
            profilePageVC.user = viewUser
        } else if segue.identifier == "ToEditPostSegueIdentifier",
                  let editPostVC = segue.destination as? CreatePostVC {
            let post = sender as! Post
            editPostVC.post = post
        } else if segue.identifier == "ToSinglePostSegue",
                  let postVC = segue.destination as? PostViewController {
            let viewPost = sender as! Post
            postVC.post = viewPost
            postVC.whichFeed = viewPost.whichFeed
        }
    }
}
