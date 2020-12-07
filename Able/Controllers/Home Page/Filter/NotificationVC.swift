//
//  NotificationVC.swift
//  Able
//
//  Created by Andre Tran on 12/6/20.
//

import UIKit
import Firebase

protocol ToProfile {
    func segueToProfilePage(userKey: String)
}

protocol ToPost {
    func segueToPost(notification: NotificationObj)
}

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var commenterImage: UIImageView!
    @IBOutlet weak var commenterName: UILabel!
    @IBOutlet weak var timeAgo: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    var delegate: UIViewController?
    
    var notification: NotificationObj! {
        didSet{
            updateUI()
            addTapGesturesForProfileClick()
        }
    }
    
    func updateUI() {
        commenterName.text = notification.fullname
        timeAgo.text = notification.timestamp?.calenderTimeSinceNow()
        comment.text = "\"\(notification.text!)\""
        ImageService.downloadImage(withURL: URL(string: notification.pictureUrl!)!) { image in
            self.commenterImage.image = image
        }
    }
    
    /// makes the commenter's profile image and their name clickable that will segue to the profile page
    func addTapGesturesForProfileClick() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(profileClicked))
        commenterImage.isUserInteractionEnabled = true
        commenterImage.addGestureRecognizer(singleTap)
        
        commenterName.isUserInteractionEnabled = true
        commenterName.addGestureRecognizer(singleTap)
    }
    
    /// when pressed segues to post. Post id/key can be accessed using notification.postId
    @IBAction func goToPostButton(_ sender: Any) {
        let notificationVC = delegate as! ToPost
        notificationVC.segueToPost(notification: notification)
    }
    
    /// segue to profile page
    @objc func profileClicked() {
        let userKey = notification.commenterKey!
        let notificationVC = delegate as! ToProfile
        notificationVC.segueToProfilePage(userKey: userKey)
    }
        
}

class NotificationVC:  UIViewController, UITableViewDelegate, UITableViewDataSource, ToProfile, ToPost {
    
    @IBOutlet weak var notificationTableView: UITableView!
    @IBOutlet weak var sortButtonLabel: UIButton!
    var fetchedNotifications = [NotificationObj]()
    var sortState:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        self.sortState = "Most Recent"
        sortNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchNotifications()
    }
    
    // MARK:- Sort Functions
    
    @IBAction func sortButton(_ sender: Any) {
        // toggle state
        if sortState == "Most Recent" {
            sortState = "Oldest First"
        }else{
            sortState = "Most Recent"
        }
        
        sortNotifications()
    }
    
    func sortNotifications(){        
        if self.sortState == "Most Recent" {
            print("ELLOOO")
            fetchedNotifications = fetchedNotifications.sorted(by: { $0.timestamp! > $1.timestamp! })
        }else{
            fetchedNotifications = fetchedNotifications.sorted(by: { $0.timestamp! < $1.timestamp! })
        }
        self.sortButtonLabel.setTitle(self.sortState, for: .normal)
        self.notificationTableView.reloadData()
    }
    
    // MARK:- Table View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedNotifications.count
    }
    
    /// animation to deselectrow
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        notificationTableView.deselectRow(at: indexPath, animated: true)
        
        let notification = fetchedNotifications[indexPath.row]
        segueToPost(notification: notification)
    }
    
    /// custom cell for table view
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notificationTableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath as IndexPath) as! NotificationCell
        
        let row = indexPath.row
        cell.notification = fetchedNotifications[row]
        cell.delegate = self
        return cell
    }
    
    /// segue to profile page when profile image is clicked
    func segueToProfilePage(userKey: String) {

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
                self.performSegue(withIdentifier: "ToProfileFromNotifications", sender: viewUser)
            }
        })
    }
    
    /// segue to the post when the cell or the button is clicked
    func segueToPost(notification: NotificationObj) {
        let whichFeed = notification.whichFeed!
        let postID = notification.postId!
        
        let postRef = Database.database().reference().child("posts").child(whichFeed).child(postID)
        
        postRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:Any],
               let userKey = dict["userKey"] as? String,
               let authorName = dict["authorName"] as? String,
               let location = dict["location"] as? String,
               let tags = dict["tags"] as? [String],
               let text = dict["text"] as? String,
               let timestamp = dict["timestamp"] as? Double,
               let completed = dict["completed"] as? Bool {
                var numComments = 0
                if let anyComments = dict["comments"] as? [String: Any] {
                    numComments = anyComments.count
                }
                let post = Post(id: postID, userKey: userKey, authorName: authorName, location: location, tags: tags, text: text, timestamp: timestamp, numComments: numComments)
                post.whichFeed = whichFeed
                post.completed = completed
                
                self.performSegue(withIdentifier: "ToSinglePostSegue", sender: post)
            }
        })
    }
    
    // MARK:- Fetch Notifications
    
    /// fetch all notifications from current user through firebase
    func fetchNotifications(){
        let notificationRef = Database
            .database()
            .reference()
            .child("users")
            .child(publicCurrentUser!.safeEmail)
            .child("notifications")
        
        notificationRef.observeSingleEvent(of: .value) { snapshot in
            
            var tempNotifications = [NotificationObj]()
            
            for notification in snapshot.children {
                if let notificationSnap = notification as? DataSnapshot,
                   let notificationData = notificationSnap.value as? [String: Any],
                   let commenterKey = notificationData["commenterKey"] as? String,
                   let fullname = notificationData["fullname"] as? String,
                   let pictureUrl = notificationData["pictureUrl"] as? String,
                   let whichFeed = notificationData["whichFeed"] as? String,
                   let postId = notificationData["postId"] as? String,
                   let timestamp = notificationData["timestamp"] as? Double,
                   let text = notificationData["text"] as? String,
                   let type = notificationData["type"] as? String
                   {
                    
                    let notif = NotificationObj(commenterKey: commenterKey,
                                                fullname: fullname,
                                                pictureUrl: pictureUrl,
                                                whichFeed: whichFeed,
                                                postId: postId,
                                                timestamp: timestamp,
                                                text: text,
                                                type: type)
                    notif.printInfo()
                    tempNotifications.append(notif)
                }
            }
            self.fetchedNotifications = tempNotifications
            self.sortNotifications()
            self.notificationTableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToSinglePostSegue",
           let postVC = segue.destination as? PostViewController {
            let viewPost = sender as! Post
            postVC.post = viewPost
            postVC.whichFeed = viewPost.whichFeed
        } else if segue.identifier == "ToProfileFromNotifications",
                  let profilePageVC = segue.destination as? ProfileVC {
            let viewUser = sender as! AbleUser
            profilePageVC.user = viewUser
          }
    }
}
