//
//  PostViewController.swift
//  Able
//
//  Created by Tim Nguyen on 10/30/20.
//

import UIKit
import Firebase

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var nameButtonLabel: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var post: Post! {
        didSet {
            getUserProfilePic()
            updateUI()
        }
    }
    
    func updateUI() {
        nameButtonLabel.setTitle(post.authorName, for: .normal)
        commentLabel.text = post.text
        timestampLabel.text = post.createdAt.calenderTimeSinceNow()
//        locationLabel.text = post.location
    }
    
    func getUserProfilePic() {
        let userKey = post.userKey
        
        let usersRef = Database.database().reference()
        
        usersRef.child("users").child(userKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userData = snapshot.value as? [String:Any],
               let profileURL = userData["photoURL"] as? String {
                // retrieve url from firebase
                ImageService.downloadImage(withURL: URL(string: profileURL)!) { image in
                    self.profilePicImageView.image = image
                }
            }
        })
    }
}


class PostViewController: UIViewController,
                          UICollectionViewDelegate, UICollectionViewDataSource,
                          UICollectionViewDelegateFlowLayout,
                          UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet weak var nameButtonLabel: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var commentsTableView: UITableView!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    var comments = [Post]()
    
    var post: Post?
    var whichFeed: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameButtonLabel.setTitle(post?.authorName, for: .normal)
        locationLabel.text = post?.location
        timestampLabel.text = post?.createdAt.calenderTimeSinceNow()
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
        textLabel.text = post?.text
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        getUserProfilePic()
        self.fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchComments()
    }
    
    func getUserProfilePic() {
        let userKey = post!.userKey
        
        let usersRef = Database.database().reference()
        
        usersRef.child("users").child(userKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userData = snapshot.value as? [String:Any],
               let profileURL = userData["photoURL"] as? String {
                // retrieve url from firebase
                ImageService.downloadImage(withURL: URL(string: profileURL)!) { image in
                    self.profilePicImageView.image = image
                }
            }
        })
    }
    
    // TAGS
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (post?.tags!.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostTagsCollectionCell", for: indexPath as IndexPath) as! TagCollectionViewCell

        let row = indexPath.row
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.tagLabel.text = post?.tags![row] // The row value is the same as the index of the desired text within the array.
        cell.backgroundColor = DEFAULT_COLOR_TAGS[row % 9] // make cell more visible in our example project
        cell.layer.cornerRadius = 8
        return cell
    }
    
    // if there is only one cell, align it to the top left of the collectionview
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView.numberOfItems(inSection: section) == 1 {
            
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width)

        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // COMMENTS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commentsTableView.dequeueReusableCell(withIdentifier: "CommentCellIdentifier", for: indexPath as IndexPath) as! CommentTableViewCell
        let row = indexPath.row
        cell.post = comments[row]
        cell.nameButtonLabel.tag = indexPath.row
        return cell
    }
    
    // animation to deselectrow
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func fetchComments() {
        let postCommentsRef = Database.database().reference().child("posts")
            .child(whichFeed!).child(post!.id).child("comments")
        
        postCommentsRef.observe(.value, with: { snapshot in
            
            var tempComments = [Post]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let userKey = dict["userKey"] as? String,
                   let authorName = dict["authorName"] as? String,
                   let location = dict["location"] as? String,
                   let text = dict["text"] as? String,
                   let timestamp = dict["timestamp"] as? Double {
                    
                    let comment = Post(id: childSnapshot.key, userKey: userKey, authorName: authorName, location: location, text: text, timestamp: timestamp)
                    
                    tempComments.append(comment)
                }
            }
            self.comments = tempComments
            self.commentsTableView.reloadData()
        })
    }
    
    @IBAction func commentPostButtonClicked(_ sender: Any) {
        if (commentTextField.text!.isEmpty) {
            print("Comment cannot be empty")
        } else {
            uploadComment()
        }
    }
    
    func uploadComment() {
        let postRef = Database.database().reference().child("posts")
            .child(whichFeed!).child(post!.id).child("comments").childByAutoId()
        
        let commentObject = [
            "userKey": publicCurrentUser!.safeEmail,
            "authorName": "\(publicCurrentUser!.firstName!) \(publicCurrentUser!.lastName!)",
            "location": "\(publicCurrentUser!.city!), \(publicCurrentUser!.state!)",
            "text": commentTextField.text!,
            "timestamp": [".sv": "timestamp"]
        ] as [String: Any]
        
        postRef.setValue(commentObject, withCompletionBlock: { [self] error, ref in
            if error == nil {
                // clear comment text field
                commentTextField.text = ""
                self.fetchComments()
            } else {
                // handle the error
            }
        })
        
        // add a notificaiton to the author of post that was just commented on
        updateAuthorPostNotification()
    }
    
    func updateAuthorPostNotification(){
        let authorSafeEmail = post!.userKey
        
        // Make notification object to store in post author's notification array
        let notificationObject = [
            "commenterKey": publicCurrentUser!.safeEmail,
            "fullname": "\(publicCurrentUser!.firstName!) \(publicCurrentUser!.lastName!)",
            "whichFeed": post!.whichFeed!,
            "postId": post!.id,
            "pictureUrl": publicCurrentUser!.profilePicUrl,
            "timestamp": [".sv": "timestamp"],
            "text": commentTextField.text!,
            "type": "comment"
            
        ] as [String : Any]
        
        // Find the author of the post from database
        let findRef = Database.database().reference().child("users")
        findRef.observeSingleEvent(of: .value) { snapshot in
            for email in snapshot.children{
                if let emailSnapshot = email as? DataSnapshot{
                    
                    //found author of post, give them notification object in firebase
                    if emailSnapshot.key == authorSafeEmail{
                        findRef.child(emailSnapshot.key)
                            .child("notifications")
                            .childByAutoId()
                            .setValue(notificationObject)
                    }
                }
            }
        }
    }
    
    @IBAction func nameClicked(_ sender: Any) {
        let userKey = post!.userKey
        
        let usersRef = Database.database().reference()
        
        usersRef.child("users").child(userKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userData = snapshot.value as? [String:Any],
               let firstName = userData["first_name"] as? String,
               let lastName = userData["last_name"] as? String,
               let username = userData["user_name"] as? String,
               let city = userData["city"] as? String,
               let state = userData["state"] as? String,
               let url = userData["photoURL"] as? String,
               let user_description = userData["user_description"] as? String {
                
                let viewUser = AbleUser(firstName: firstName, lastName: lastName,
                                    emailAddress: snapshot.key, username: username, city: city, state: state, profilePicURL: url, userDescription: user_description)
                self.performSegue(withIdentifier: "ToProfileFromPost", sender: viewUser)
            }
        })
    }
    
    @IBAction func nameButtomFromCommentClicked(_ sender: UIButton) {
        let postIndex = IndexPath(row: sender.tag, section: 0)
        let userKey = comments[postIndex.row].userKey
        
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
                self.performSegue(withIdentifier: "ToProfileFromPost", sender: viewUser)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToProfileFromPost",
            let profilePageVC = segue.destination as? ProfileVC {
            let viewUser = sender as! AbleUser
            profilePageVC.user = viewUser
        }
    }
    
    // This closes the keyboard when touch is detected outside of the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
