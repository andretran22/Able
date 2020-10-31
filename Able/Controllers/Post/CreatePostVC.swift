//
//  CreatePostVC.swift
//  Able
//
//  Created by Tim Nguyen on 10/14/20.
//

import UIKit
import Firebase

class CreatePostTagCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tagLabel: UILabel!
}
    
class CreatePostVC: UIViewController, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionViewTags: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var segCtrlFeed: UISegmentedControl!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    
    let placeholderText = "Write something here..."
    let tagIdentifier = "CreatePostTagCell"
    
    var ref: DatabaseReference!
    var tags = DEFAULT_TAGS
    var tagColors = DEFAULT_COLOR_TAGS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up text view properly
        postTextView.delegate = self
        stylePage()
        
        collectionViewTags.delegate = self
        collectionViewTags.dataSource = self
    }
    
    func stylePage() {
        // textViewStyle
        postTextView.layer.cornerRadius = 10
        postTextView.text = placeholderText
        postTextView.textColor = UIColor.lightGray
        
        // button style
        postButton.layer.cornerRadius = 4
        
        self.nameLabel.text = "\(publicCurrentUser!.firstName!) \(publicCurrentUser!.lastName!)"
        self.locationLabel.text = "\(publicCurrentUser!.city!), \(publicCurrentUser!.state!)"
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagIdentifier, for: indexPath as IndexPath) as! CreatePostTagCollectionViewCell
        
        let row = indexPath.row
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.tagLabel.text = self.tags[row] // The row value is the same as the index of the desired text within the array.
        cell.backgroundColor = self.tagColors[row] // make cell more visible in our example project
        cell.layer.cornerRadius = 8
        return cell
    }
    
    // when clicked, check for segCtrlFeed and
    @IBAction func postButtonClicked(_ sender: Any) {
        
        var postRef = Database.database().reference().child("posts")
        
        if (segCtrlFeed.selectedSegmentIndex == 0) {
            postRef = postRef.child("helpPosts").childByAutoId()
        } else {
            postRef = postRef.child("helperPosts").childByAutoId()
        }

        let postObject = [
            "userKey": publicCurrentUser!.safeEmail,
            "authorName": "\(publicCurrentUser!.firstName!) \(publicCurrentUser!.lastName!)",
            "location": "\(publicCurrentUser!.city!), \(publicCurrentUser!.state!)",
            "text": postTextView.text!,
            "timestamp": [".sv": "timestamp"]
        ] as [String: Any]
        
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
                // self.dismiss(animated: true, completion: nil)
            } else {
                // handle the error
            }
        })
    }
}
