//
//  PostCell.swift
//  AbleHomePage
//
//  Created by Tim Nguyen on 10/20/20.
//

import UIKit
import Firebase

let MY_POST_OPTIONS = ["Mark Complete", "Edit", "Delete", "Save"]
let DEFAULT_POST_OPTIONS = ["Save"]

protocol EditPost {
    func editPost(post: Post)
}

class PostCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate,
                UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var postStatsLabel: UILabel! // works for number of comments and ratings label
//    @IBOutlet weak var postImageView: UIImageView!
    
    // only for help or helper posts
    @IBOutlet weak var tagsCollectionView: UICollectionView?
    @IBOutlet weak var numberOfCommentsLabel: UILabel?
    @IBOutlet weak var optionsTableView: UITableView?
    
    // only for review posts
    @IBOutlet weak var ratingLabel: UILabel?
    
    let ref = Database.database().reference()
    
    var delegate: UIViewController?
    var tags = [String]()
    var options = [String]()
    
    var post: Post! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        getUserProfilePic()
        usernameButton.setTitle(post.authorName, for: .normal)
        locationLabel.text = post.location
        timeAgoLabel.text = post.createdAt.calenderTimeSinceNow()
        captionLabel.text = post.text
        
        // for help and helper posts
        if (post.tags != nil) {
            tags = post.tags!
            tagsCollectionView?.delegate = self
            tagsCollectionView?.dataSource = self
            optionsTableView?.delegate = self
            optionsTableView?.dataSource = self
            
            // options logic
            if (post.userKey == publicCurrentUser!.safeEmail) {
                options = MY_POST_OPTIONS
                if (post.completed!) {
                    replaceOption(origString: "Mark Complete", newString: "Make Active")
                }
            } else {
                options = DEFAULT_POST_OPTIONS
            }
            
            if (publicCurrentUser!.savedPosts.contains(post.id)) {
                replaceOption(origString: "Save", newString: "Unsave")
            }
            optionsTableView?.reloadData()
            //tagsCollectionView?.reloadData()
        }
        
        if (post.numComments != nil) {
            postStatsLabel.text = String(post.numComments!)
        }
        
        // for reviews
        if (post.rating != nil) {
            ratingLabel?.text = String(Int(post.rating!))
        }
        
//        postStatsLabel.text = "\(post.numberOfComments!)"
    //        profileImageView.image = post.createdBy.profileImage
    //        usernameLabel.text = post.createdBy.username
    }
    
    func replaceOption(origString: String, newString: String) {
        if let index = options.firstIndex(of: origString) {
            options.remove(at: index)
            options.insert(newString, at: index)
            optionsTableView?.reloadData()
        }
    }
    
    func getUserProfilePic() {
        let userKey = post.userKey
        
        let usersRef = Database.database().reference()
        
        usersRef.child("users").child(userKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userData = snapshot.value as? [String:Any],
               let profileURL = userData["photoURL"] as? String {
                // retrieve url from firebase
                ImageService.downloadImage(withURL: URL(string: profileURL)!) { image in
                    self.profileImageView.image = image
                }
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostTagsCollectionCell", for: indexPath as IndexPath) as! TagCollectionViewCell
        
        let row = indexPath.row
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.tagLabel.text = self.tags[row] // The row value is the same as the index of the desired text within the array.
        cell.backgroundColor = DEFAULT_COLOR_TAGS[row % 9] // make cell more visible in our example project
        cell.layer.cornerRadius = 8
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = options[row]
        return cell
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    @IBAction func optionsButtonClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1,
            animations: {
                sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    sender.transform = CGAffineTransform.identity
                    self.optionsTableView!.isHidden = !self.optionsTableView!.isHidden
                }
            })
    }
    
    // handles the post options
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        switch options[row] {
        case "Mark Complete":
            print("THIS POST IS COMPLETED: \(post.id)")
            
            ref.child("posts").child(post.whichFeed!).child(post.id)
                .child("completed").setValue(true) { error, ref in
                if error != nil {
                    print("error \(String(describing: error))")
                } else {
                    print("\(self.post.id) IS MARKED COMPLETE")
                    self.replaceOption(origString: "Mark Complete", newString: "Make Active")
                }
            }
        case "Make Active":
            print("MAKE THIS POST ACTIVE AGAIN: \(post.id)")
            
            ref.child("posts").child(post.whichFeed!).child(post.id)
                .child("completed").setValue(false) { error, ref in
                if error != nil {
                    print("error \(String(describing: error))")
                } else {
                    print("\(self.post.id) IS ACTIVE AGAIN")
                    self.replaceOption(origString: "Make Active", newString: "Mark Complete")
                }
            }
        case "Edit":
            print("EDIT THIS POST: \(post.id)")
            let VC = delegate as! EditPost
            VC.editPost(post: post)
        case "Delete":
            print("DELETING THE POST WITH ID: \(post.id)")
            
            // NEED TO POP UP AN ALERT TO CONFIRM DELETION
            // Remove the post from the DB
            ref.child("posts").child(post.whichFeed!).child(post.id).removeValue { error, ref in
                if error != nil {
                    print("error \(String(describing: error))")
                } else {
                    print("\(self.post.id) IS DELETED")
                }
            }
        case "Unsave":
            print("UNSAVE THIS POST: \(post.id)")
            
            ref.child("users").child(publicCurrentUser!.safeEmail)
                .child("saved_posts").child(post.id).removeValue() { error, ref in
                    if error != nil {
                        print("error \(String(describing: error))")
                    } else {
                        print("\(self.post.id) IS DELETED")
                        self.replaceOption(origString: "Unsave", newString: "Save")
                    }
                }
        default:
            print("SAVE THIS POST: \(post.id)")
            
            // update saved posts DB
            ref.child("users").child(publicCurrentUser!.safeEmail)
                .child("saved_posts").child(post.id).setValue("")
            
            replaceOption(origString: "Save", newString: "Unsave")
        }
        
        // TODO ANIMATE THIS
        optionsTableView?.isHidden = true
    }
}
