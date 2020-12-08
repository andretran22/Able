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
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var removeImageButton: UIButton!
    
    let placeholderText = "Write something here..."
    let tagIdentifier = "CreatePostTagCell"
    
    var ref: DatabaseReference!
    var location: String = ""
    var tags = [String]()
    var imageData: Data?
    var imageURL = ""
    
    @IBOutlet weak var scrollView: UIScrollView!
    var imagePicker: UIImagePickerController!
    var scrollViewOrigHeight: CGFloat = 0
    
    // for editing posts
    var post: Post?
    var user: AbleUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = publicCurrentUser
        scrollViewOrigHeight = scrollView.contentSize.height
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
        
        // Setup imagePicker to change the profile image, profileImage crop
        initializeProfilePhotoElements()
    }
    
    func initializeProfilePhotoElements() {
        // initialize imagePicker
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        // format profile image display
//        profileImageView.layer.masksToBounds = true
//        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
    }
    
    // change the profile image of the user
    @IBAction func addImage(_ sender: Any) {
        present(self.imagePicker, animated: true)
    }
    
    // remove image
    @IBAction func removeImage(_ sender: Any) {
        if post != nil && post!.image != nil {
            let controller = UIAlertController(title: "Image Deletion",
                                               message: "Are you sure you want to delete your image? (This action cannot be undone.)",
                                               preferredStyle: .alert)
            
            controller.addAction(UIAlertAction(title: "Cancel",
                                               style: .cancel,
                                               handler: nil))
            
            controller.addAction(UIAlertAction(title: "Delete",
                                               style: .destructive,
                                               handler: { (action) in
                                                // Create a reference to the file to delete
                                                let imageRef = Storage.storage().reference().child("posts/\(self.post!.whichFeed!)/\(self.post!.id)")

                                                // Delete the file
                                                imageRef.delete { error in
                                                  if let error = error {
                                                    print("error \(error)")
                                                    // Uh-oh, an error occurred!
                                                  } else {
                                                    // File deleted successfully
                                                    self.removeImageButton.isHidden = true
                                                    self.postImageView.image = nil
                                                    self.imageData = nil
                                                    self.imageURL = ""
                                                    self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.scrollViewOrigHeight)
                                                  }
                                                }
                                               }))
            present(controller, animated: true, completion: nil)
        } else {
            removeImageButton.isHidden = true
            postImageView.image = nil
            imageData = nil
            scrollView.contentSize = CGSize(width: self.view.frame.width, height: scrollViewOrigHeight)
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
        
        removeImageButton.isHidden = true
        postImageView.image = nil
        
        errorStatusLabel.isHidden = true
        collectionViewTags.reloadData()
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
        
        if (post!.image != nil) {
            ImageService.downloadImage(withURL: URL(string: post!.image!)!) { image in
                self.postImageView!.image = image
            }
            removeImageButton.isHidden = false
            self.imageURL = post!.image!
            scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+100)
        }
    }
    
    func stylePage() {
        
        ImageService.downloadImage(withURL: URL(string: publicCurrentUser!.profilePicUrl)!) { image in
            self.profilePicImage.image = image
            self.profilePicImage.layer.masksToBounds = true
            self.profilePicImage.layer.cornerRadius = self.profilePicImage.bounds.width / 2
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
            prepareToUploadPost()
        }
    }
    
    // uploads post to firebase in helpPosts or helperPosts
    func prepareToUploadPost() {
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
        
        var whichFeed = "helpPosts"
        
        // check for which segCtrlFeed
        if (segCtrlFeed.selectedSegmentIndex == 1) {
            whichFeed = "helperPosts"
        }
        
        postRef = postRef.child(whichFeed)
        
        // if post is nil, create a new post
        // else, update and overwrite existing post
        if (post == nil) {
            postRef = postRef.childByAutoId()
        } else {
            postRef = postRef.child(post!.id)
        }
        
        if postImageView.image != nil {
            // get storage reference, set metedata
            guard let key = postRef.key else { return }
            let storageRef = Storage.storage().reference().child("posts/\(whichFeed)/\(key)")
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            // insert new image into database
            storageRef.putData(imageData!, metadata: metaData, completion: { _, error in
                guard error == nil else {
                    print("Failed to upload")
                    return
                }
                
                // get the created url
                storageRef.downloadURL(completion: {url, error in
                    guard let url = url, error == nil else {
                        return
                    }
                    
                    // set local and firebase user url to the new url
                    let urlString = url.absoluteString
                    print("downloadURL: \(urlString)")
                    
                    self.imageURL = urlString
                    self.uploadPost(postRef: postRef)
                })
            })
        } else {
            uploadPost(postRef: postRef)
        }
    }
    
    func uploadPost(postRef: DatabaseReference) {
        var postObject = [
            "userKey": publicCurrentUser!.safeEmail,
            "authorName": "\(publicCurrentUser!.firstName!) \(publicCurrentUser!.lastName!)",
            "location": location,
            "tags": tags,
            "text": postTextView.text!,
            "timestamp": [".sv": "timestamp"],
            "completed": false,
            "image": imageURL
        ] as [String: Any]
        
        if imageURL == "" {
            postObject.removeValue(forKey: "image")
        }
        
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

extension CreatePostVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // dismiss imagePicker when cancel is pressed
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // gets image from imagePicker and updates/uploads new image to profile picture and Firebase
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // get the image from photolibrary
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        // set the profile image to the new image
        self.imageData = imageData
        postImageView.image = image
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+100)
        
        removeImageButton.isHidden = false
        
        picker.dismiss(animated: true, completion: nil)
    }
}
