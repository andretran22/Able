//
//  CreatePostVC.swift
//  Able
//
//  Created by Tim Nguyen on 10/14/20.
//

import UIKit
import Firebase

protocol ApplyTags {
    func addTags(newTags: [String])
}

protocol ChangeLocation {
    func changeLocation(location: String)
}

class CreatePostVC: UIViewController, UITextViewDelegate,
                    UICollectionViewDataSource, UICollectionViewDelegate,
                    UICollectionViewDelegateFlowLayout,
                    ApplyTags, ChangeLocation {

    @IBOutlet weak var collectionViewTags: UICollectionView!
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var segCtrlFeed: UISegmentedControl!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var errorStatusLabel: UILabel!
    
    let placeholderText = "Write something here..."
    let tagIdentifier = "CreatePostTagCell"
    
    var ref: DatabaseReference!
    var location: String = ""
    var tags = [String]()
    
    // for editing posts
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up text view properly
        postTextView.delegate = self
        stylePage()
        
        collectionViewTags.delegate = self
        collectionViewTags.dataSource = self
        
        // if the post is nil, then we are creating a new post
        // else, we are editing an existing post
        if (post == nil) {
            resetOriginalPostParameters()
        } else {
            useExistingPostParameters()
        }
    }
    
    // use default post info
    func resetOriginalPostParameters() {
        
        // reset to help feed
        segCtrlFeed.selectedSegmentIndex = 0
        
        // reset location to user's location
        location = "\(publicCurrentUser!.city!), \(publicCurrentUser!.state!)"
        self.locationButton.setTitle(location, for: .normal)
        
        // empty tags
        tags = [String]()
        
        // clear text and revert back to placeholder text
        postTextView.text = placeholderText
        postTextView.textColor = UIColor.lightGray
    }
    
    // apply existing post info to UI elements
    func useExistingPostParameters() {
        
        if (post?.whichFeed == "helpPosts") {
            segCtrlFeed.selectedSegmentIndex = 0
        } else {
            segCtrlFeed.selectedSegmentIndex = 1
        }
        
        location = post!.location
        self.locationButton.setTitle(location, for: .normal)
        
        tags = post!.tags!
        
        postTextView.text = post!.text
    }
    
    func stylePage() {
        
        ImageService.downloadImage(withURL: URL(string: publicCurrentUser!.profilePicUrl)!) { image in
            self.profilePicImage.image = image
        }
        
        // textViewStyle
        postTextView.layer.cornerRadius = 10
        
        // button style
        postButton.layer.cornerRadius = 4
        
        self.nameLabel.text = "\(publicCurrentUser!.firstName!) \(publicCurrentUser!.lastName!)"
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagIdentifier, for: indexPath as IndexPath) as! TagCollectionViewCell
        
        let row = indexPath.row
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.tagLabel.text = self.tags[row] // The row value is the same as the index of the desired text within the array.
        cell.backgroundColor = DEFAULT_COLOR_TAGS[row % 9]// make cell more visible in our example project
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
    
    // checks if fields are filled out properly first and then uploads post
    @IBAction func postButtonClicked(_ sender: Any) {
        // there must be at least one tag
        if (postTextView.text.isEmpty || postTextView.text! == placeholderText) {
            errorStatusLabel.text = "Post cannot be empty"
            errorStatusLabel.isHidden = false
        } else if (tags.count == 0) {
            errorStatusLabel.text = "Post must have at least one tag"
            errorStatusLabel.isHidden = false
        } else {
            uploadPost()
            tags = [String]()
            postTextView.text = placeholderText
            postTextView.textColor = UIColor.lightGray
            errorStatusLabel.isHidden = true
            collectionViewTags.reloadData()
        }
    }
    
    // uploads post to firebase in helpPosts or helperPosts
    func uploadPost() {
        var postRef = Database.database().reference().child("posts")
        
        // delete the post just in case if the user switches feeds
        if (post != nil) {
            postRef.child(post!.whichFeed!).child(post!.id).removeValue { error, ref in
                if error != nil {
                    print("error \(String(describing: error))")
                } else {
                    print("\(self.post!.id) IS DELETED")
                }
            }
        }
        
        // check for which segCtrlFeed
        if (segCtrlFeed.selectedSegmentIndex == 0) {
            postRef = postRef.child("helpPosts")
        } else {
            postRef = postRef.child("helperPosts")
        }
        
        // if post is nil, create a new post
        // else, update and overwrite existing post
        if (post == nil) {
            postRef = postRef.childByAutoId()
        } else {
            postRef = postRef.child(post!.id)
        }
        
        let postObject = [
            "userKey": publicCurrentUser!.safeEmail,
            "authorName": "\(publicCurrentUser!.firstName!) \(publicCurrentUser!.lastName!)",
            "location": location,
            "tags": tags,
            "text": postTextView.text!,
            "timestamp": [".sv": "timestamp"],
            "completed": false
        ] as [String: Any]
        
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
                self.resetOriginalPostParameters()
                if (self.post != nil) {
                    self.navigationController?.popViewController(animated: true)
                }
                self.tabBarController?.selectedIndex = 0
            } else {
                // handle the error
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddTagsPopover",
           let addTagsVC = segue.destination as? AddTagsViewController {
            addTagsVC.delegate = self
            addTagsVC.yourTags = tags
        } else if segue.identifier == "ChangeLocation",
                  let changeLocationVC = segue.destination as? LocationViewController  {
            changeLocationVC.delegate = self
            print("CHANGE LOCATION")
        }
    }
    
    func addTags(newTags: [String]) {
        tags = newTags
        collectionViewTags.reloadData()
    }
    
    func changeLocation(location: String) {
        self.location = location
        self.locationButton.setTitle(location, for: .normal)
    }
    
    // This closes the keyboard when touch is detected outside of the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
