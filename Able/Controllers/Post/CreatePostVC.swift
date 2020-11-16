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
                    ApplyTags, ChangeLocation {

    @IBOutlet weak var collectionViewTags: UICollectionView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up text view properly
        postTextView.delegate = self
        stylePage()
        
        collectionViewTags.delegate = self
        collectionViewTags.dataSource = self
        
        resetOriginalPostParameters()
    }
    
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
    
    func stylePage() {
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
        
        // check for which segCtrlFeed
        if (segCtrlFeed.selectedSegmentIndex == 0) {
            postRef = postRef.child("helpPosts").childByAutoId()
        } else {
            postRef = postRef.child("helperPosts").childByAutoId()
        }
        
        let postObject = [
            "userKey": publicCurrentUser!.safeEmail,
            "authorName": "\(publicCurrentUser!.firstName!) \(publicCurrentUser!.lastName!)",
            "location": location,
            "tags": tags,
            "text": postTextView.text!,
            "timestamp": [".sv": "timestamp"]
        ] as [String: Any]
        
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
                self.resetOriginalPostParameters()
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
