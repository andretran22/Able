//
//  PersonalHelpFeedVC.swift
//  Able
//
//  Created by Ziyi Liew on 3/11/20.
//

import UIKit
import Firebase

class PersonalHelpFeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var helpPosts = [Post]()
    var viewUser: AbleUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchPosts()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        let pCurrentUser = publicCurrentUser
        
        if (viewUser == nil) {
            viewUser = publicCurrentUser
        }
        print("CURRENTLY VIEWING THIS USER Help Feed")
//        print(viewUser!.safeEmail)
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
                   let completed = dict["completed"] as? Bool {
//                    print("email is " + userKey + " viewUser safe email is " + self.viewUser!.safeEmail)
                    if userKey == self.viewUser?.safeEmail {
//                        print("adding post to tempPosts")
                        
                        var numComments = 0
                        if let anyComments = dict["comments"] as? [String: Any] {
                            numComments = anyComments.count
                        }
                        let post = Post(id: childSnapshot.key, userKey: userKey, authorName: authorName, location: location, tags: tags, text: text, timestamp: timestamp, numComments: numComments)
                        post.completed = completed
                        post.whichFeed = "helpPosts"
                        tempPosts.append(post)
                    }
                }
            }
            self.helpPosts = tempPosts
            self.tableView.reloadData()
        })
    }
    
    // animation to deselect cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpPostCell", for: indexPath) as! PostCell
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
               let url = userData["photoURL"] as? String,
               let state = userData["state"] as? String
               {
                self.viewUser = AbleUser(firstName: firstName, lastName: lastName,
                                    emailAddress: snapshot.key, username: username, city: city, state: state, profilePicURL: url)
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

