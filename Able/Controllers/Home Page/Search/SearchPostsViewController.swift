//
//  SearchPostsViewController.swift
//  Able
//
//  Created by Tim Nguyen on 10/30/20.
//

import UIKit
import Firebase
import Foundation

class SearchPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditPost, DeletePost {
    
    @IBOutlet weak var postsTableView: UITableView!
    public var filteredPostList:[Post] = []
    public var help1 = true
    let postsCellIdentifier = "PostCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsTableView.delegate = self
        postsTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPostList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: postsCellIdentifier, for: indexPath as IndexPath) as! PostCell
        cell.post = filteredPostList[indexPath.row]
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //this function gets executed when you tap a row
        tableView.deselectRow(at: indexPath, animated: true)
        let post = filteredPostList[indexPath.row]
        self.performSegue(withIdentifier: "searchPostToPost", sender: post)
    }
    
    public func updateTableView(){
        postsTableView.reloadData()
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
                                                    print("\(post.id) IS DELETED")
                                                    if let index = self.filteredPostList.firstIndex(of: post) {
                                                        self.filteredPostList.remove(at: index)
                                                        self.postsTableView.reloadData()
                                                    }
                                                }
                                            }
                                           }))
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func nameClicked(_ sender: UIButton) {
        let postIndex = IndexPath(row: sender.tag, section: 0)
        let userKey = filteredPostList[postIndex.row].userKey
        
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
                self.performSegue(withIdentifier: "ToProfileFromSearchFeed", sender: viewUser)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchPostToPost",
            let postPage = segue.destination as? PostViewController {
            let post = sender as! Post
            postPage.post = post
            if(help1){
                postPage.whichFeed = "helpPosts"
            }else{
                postPage.whichFeed = "helperPosts"
            }
        } else if segue.identifier == "ToEditPostSegueIdentifier",
                  let editPostVC = segue.destination as? CreatePostVC {
            let post = sender as! Post
            editPostVC.post = post
        } else if segue.identifier == "ToProfileFromSearchFeed",
                  let profilePageVC = segue.destination as? ProfileVC {
            let viewUser = sender as! AbleUser
            profilePageVC.user = viewUser
        }
    }
    
}
