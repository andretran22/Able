//
//  HelpFeedVC.swift
//  Able
//
//  Created by Tim Nguyen on 10/16/20.
//

import UIKit
import Firebase

class HelpFeedVC: UITableViewController, EditPost, DeletePost {
    
    var helpPosts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchPosts()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchPosts()
    }
    
    func fetchPosts() {
        let helpPostsRef = Database.database().reference().child("posts").child("helpPosts")
        
        helpPostsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
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
                    if let imageURL = dict["image"] as? String {
                        post.image = imageURL
                    }
                    tempPosts.append(post)
                }
            }
            
            //filter tempPosts and sort them
            tempPosts = (globalFilterState?.sortAndFilter(postType: "helpPosts", posts: tempPosts))!
            
            self.helpPosts = tempPosts
            self.tableView.reloadWithAnimation()
        })
    }
    
    // Called from Home Page when Quick Categories are pressed.
    func setFeedToCategory() {
        globalFilterState?.printInfo()
        fetchPosts()
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
        
        let post = helpPosts[indexPath.row]
        var whichPostCell = "HelpPostCell"
        if post.image != nil {
            whichPostCell = "HelpPostCellWithImage"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: whichPostCell, for: indexPath) as! PostCell
        cell.delegate = self
        cell.post = post
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = helpPosts[indexPath.row]
        if (post.image != nil) {
            return 320
        }
        return 220
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
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
                                                    if let index = self.helpPosts.firstIndex(of: post) {
                                                        self.helpPosts.remove(at: index)
                                                        self.tableView.reloadWithAnimation()
                                                    }
                                                }
                                            }
                                           }))
        
        present(controller, animated: true, completion: nil)
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
        } else if segue.identifier == "ToEditPostSegueIdentifier",
                  let editPostVC = segue.destination as? CreatePostVC {
            let post = sender as! Post
            editPostVC.post = post
        }
    }
}

extension UITableView {

    func reloadWithAnimation() {
        self.reloadData()
        let tableViewHeight = self.bounds.size.height
        let cells = self.visibleCells
        var delayCounter = 0
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        for cell in cells {
            UIView.animate(withDuration: 1.6, delay: 0.08 * Double(delayCounter),usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
}
