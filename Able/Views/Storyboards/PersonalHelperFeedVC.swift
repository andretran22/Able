//
//  PersonalHelperFeedVC.swift
//  Able
//
//  Created by Ziyi Liew on 3/11/20.
//

import UIKit
import Firebase

class PersonalHelperFeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, EditPost, DeletePost {
    
    @IBOutlet weak var tableView: UITableView!
    var helperPosts = [Post]()
    var viewUser: AbleUser?
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchPosts()
        tableView.delegate = self
        tableView.dataSource = self
        
        if (viewUser == nil) {
            viewUser = publicCurrentUser
        }
        print("CURRENTLY VIEWING THIS USER Helper Feed")
//        print(viewUser!.safeEmail)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchPosts()
    }
    
    func fetchPosts() {
        let helperPostsRef = Database.database().reference().child("posts").child("helperPosts")
        
        helperPostsRef.observe(.value, with: { snapshot in
            
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
                   let completed = dict["completed"] as? Bool {
                    print("email is " + userKey + " viewUser safe email is " + self.viewUser!.safeEmail)
                    if userKey == self.viewUser?.safeEmail {
                        print("adding post to tempPosts")
                        
                        var numComments = 0
                        if let anyComments = dict["comments"] as? [String: Any] {
                            numComments = anyComments.count
                        }
                        let post = Post(id: childSnapshot.key, userKey: userKey, authorName: authorName, location: location, tags: tags, text: text, timestamp: timestamp, numComments: numComments)
                        post.completed = completed
                        post.whichFeed = "helperPosts"
                        if let imageURL = dict["image"] as? String {
                            post.image = imageURL
                        }
                        tempPosts.append(post)
                    }
                }
            }
            self.helperPosts = tempPosts.reversed()
            let profileVC = self.delegate as! PassTheHelperPosts
            profileVC.passHelperPosts(post: self.helperPosts)
            self.tableView.reloadWithAnimation()
        })
    }
    
    // animation to deselect cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "ToSinglePostSegue", sender: helperPosts[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helperPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = helperPosts[indexPath.row]
        var whichPostCell = "HelperPostCell"
        if post.image != nil {
            whichPostCell = "HelperPostCellWithImage"
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
        let post = helperPosts[indexPath.row]
        if (post.image != nil) {
            return 320
        }
        return 220
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
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
                                                    if let index = self.helperPosts.firstIndex(of: post) {
                                                        self.helperPosts.remove(at: index)
                                                        self.tableView.reloadWithAnimation()
                                                    }
                                                }
                                            }
                                           }))
        
        present(controller, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToEditPostSegueIdentifier",
                  let editPostVC = segue.destination as? CreatePostVC {
            let post = sender as! Post
            editPostVC.post = post
        } else if segue.identifier == "ToSinglePostSegue",
                  let postVC = segue.destination as? PostViewController {
            let viewPost = sender as! Post
            postVC.post = viewPost
            postVC.whichFeed = "helperPosts"
        }
    }
}
