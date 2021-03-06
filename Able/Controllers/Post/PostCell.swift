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

protocol DeletePost {
    func deletePost(post: Post)
}

protocol UnsavePost {
    func unsavePost(post: Post)
}

class PostCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate,
                UICollectionViewDelegateFlowLayout,
                UITableViewDelegate, UITableViewDataSource {
    
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
    @IBOutlet weak var postImageView: UIImageView?
    
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
            tagsCollectionView?.delegate = self
            tagsCollectionView?.dataSource = self
            
            tags = post.tags!
            tagsCollectionView?.reloadData()
            
            optionsTableView?.delegate = self
            optionsTableView?.dataSource = self
            optionsTableView?.layer.cornerRadius = 10
            
            if publicCurrentUser != nil {
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
            if (post.image != nil) {
                ImageService.downloadImage(withURL: URL(string: post.image!)!) { image in
                    self.postImageView!.image = image
                    self.postImageView!.layer.masksToBounds = true
                    self.postImageView!.layer.cornerRadius = 10
                }
            }
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
                    self.profileImageView.layer.masksToBounds = true
                    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.width / 2
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
    
    // if there is only one cell, align it to the top left of the collectionview
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView.numberOfItems(inSection: section) == 1 {
            
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width)

        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
                    if (self.optionsTableView!.isHidden) {
                        self.contentView.backgroundColor = UIColor.white
                        self.tagsCollectionView?.backgroundColor = UIColor.white
                    } else {
                        self.contentView.backgroundColor = UIColor.lightGray
                        self.tagsCollectionView?.backgroundColor = UIColor.lightGray
                    }
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
            let VC = delegate as! DeletePost
            VC.deletePost(post: post)
        case "Unsave":
            print("UNSAVE THIS POST: \(post.id)")
            
            ref.child("users").child(publicCurrentUser!.safeEmail)
                .child("saved_posts").child(post.id).removeValue() { error, ref in
                    if error != nil {
                        print("error \(String(describing: error))")
                    } else {
                        print("\(self.post.id) IS DELETED FROM SAVED POSTS")
                        self.replaceOption(origString: "Unsave", newString: "Save")
                        if let index = publicCurrentUser?.savedPosts.firstIndex(of: self.post.id) {
                            publicCurrentUser?.savedPosts.remove(at: index)
                            let VC = self.delegate as! UnsavePost
                            VC.unsavePost(post: self.post) // reloads the table view data
                        }
                    }
                }
        default:
            print("SAVE THIS POST: \(post.id)")
            
            publicCurrentUser?.savedPosts.append(post.id)
            
            // update saved posts DB
            ref.child("users").child(publicCurrentUser!.safeEmail)
                .child("saved_posts").child(post.id).setValue("")
            
            replaceOption(origString: "Save", newString: "Unsave")
        }
        
        // TODO ANIMATE THIS
        
        optionsTableView?.isHidden = true
        contentView.backgroundColor = UIColor.white
        tagsCollectionView?.backgroundColor = UIColor.white
    }
}
