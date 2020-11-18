//
//  ProfileVC.swift
//  Able
//
//  Created by Ziyi Liew on 15/10/20.
//

import UIKit
import Firebase

class ProfileVC: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tapToChangeProfileButton: UIButton!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var helpFeedContainer: UIView!
    @IBOutlet weak var helperFeedContainer: UIView!
    @IBOutlet weak var savedFeedContainer: UIView!
    @IBOutlet weak var segmentedControlWithSaved: UISegmentedControl!
    @IBOutlet weak var segmentedControlWithoutSaved: UISegmentedControl!
    @IBOutlet weak var settingsButton: UIButton!
    
    
    var ref: DatabaseReference!
    var imagePicker: UIImagePickerController!
    
    // use this variable once we set up the segues
    var passedInUid = String()
    
    // user's profile
    var user: AbleUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display help feed upon loading, hide the other feeds
        helpFeedView()
        
        // Setup imagePicker to change the profile image, profileImage crop
        initializeProfilePhotoElements()
        
        // set up appropriate segmentedControl depending on who's visiting
        setSegmentedControlView()
        
        // fetch and display user info from Firebase
        displayInfo()
        
        // set the user's rating
        setRating(uid: user!.safeEmail)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayInfo()
        setRating(uid: user!.safeEmail)
    }
    
    // switches between the help, helper, and saved container views
    @IBAction func switchViews(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                helpFeedView()
                print("In helpFeedContainer")
            case 1:
                helperFeedView()
                print("In helperFeedContainer")
            case 2:
                savedFeedView()
                print("In savedFeedContainer")
            default:
                helpFeedView()
                print("Should not hit here, default case of switchViews")
        }
    }
    
    
    
    // button that changes the aboutMeLabel text when the aboutMeButton is pressed
    @IBAction func editAboutMe(_ sender: Any) {
        if user?.safeEmail != publicCurrentUser?.safeEmail { return }
        let controller = UIAlertController(title: "About me",
                                           message: "Edit my profile description",
                                           preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Cancel",
                                           style: .cancel,
                                           handler: nil))
        
        controller.addTextField(configurationHandler: {
            (textField:UITextField!) in textField.placeholder = ""
        })
        
        controller.addAction(UIAlertAction(title: "OK",
                                           style: .default,
                                           handler: {
                                            (paramAction:UIAlertAction!) in
                                            if let textFieldArray = controller.textFields {
                                                let textFields = textFieldArray as [UITextField]
                                                self.aboutMeLabel.text = textFields[0].text
                                                self.user?.userDescription = textFields[0].text
                                                self.ref = Database.database().reference()
                                                self.ref.child("users").child(self.user!.safeEmail).child("user_description").setValue(textFields[0].text)
                                            }
                }))
        
        present(controller, animated: true, completion: nil)
    }
    
    // change the profile image of the user
    @IBAction func changeProfileImage(_ sender: Any) {
        present(imagePicker, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "personalHelpSegue",
            let profilePageVC = segue.destination as? PersonalHelpFeedVC {
            profilePageVC.viewUser = user
        }
        
        if segue.identifier == "personalHelperSegue",
           let profilePageVC = segue.destination as? PersonalHelperFeedVC {
           profilePageVC.viewUser = user
       }
        
        if segue.identifier == "savedSegue",
           let profilePageVC = segue.destination as? SavedFeedVC {
           profilePageVC.viewUser = user
       }
        
        if segue.identifier == "reviewSegue",
           let profilePageVC = segue.destination as? ReviewVC {
           profilePageVC.viewUser = user
       }
    }
}

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        profileImageView.image = image
        
        // get storage reference, set metedata
        guard let uid = user?.safeEmail else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        // insert new image into database
        storageRef.putData(imageData, metadata: metaData, completion: { _, error in
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
                self.user?.profilePicUrl = urlString
                
                guard let uid = self.user?.safeEmail else { return }
                self.ref = Database.database().reference().child("users/\(uid)")
                self.ref.observeSingleEvent(of: .value, with: {
                    (snapshot) in
                    self.ref.child("photoURL").setValue(urlString)
                }) { (error) in
        //            completion(error == nil)
                }
            })
        })

        print("profilePicURL set to : \(String(describing: user?.profilePicUrl))")
        picker.dismiss(animated: true, completion: nil)
    }
    
    // sets the ratingButton text from data retrieved from Firebase
    func setRating(uid: String) {
        ref = Database.database().reference()
        ref.child("users").child(uid).child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
            if let getData = snapshot.value as? [String:Any] {
                let numReviews = (getData["numReviews"] as? Int)!
                var rating = 0.0
                if numReviews != 0 {
                    for i in 1...numReviews {
                        let currentId = (getData["review\(i)"] as? [String:Any])!
                        let ratingTemp = (currentId["rating"] as? Double)!
                        rating = ratingTemp + rating
                    }
                    rating = rating / Double(numReviews)
                    let formattedRating = String(format: "%.1f", rating)
                    let finalRating = "\(formattedRating) (\(numReviews))"
                    self.ratingButton.setTitle(finalRating, for: .normal)
                } else {
                    self.ratingButton.setTitle("No rating", for: .normal)
                }
            } else {
                self.ratingButton.setTitle("No rating", for: .normal)
            }
          }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // Display the user's information on the Profile page
    func displayInfo() {
        self.nameLabel.text = "\(user!.firstName!) \(user!.lastName!)"
        self.locationLabel.text = "\(user!.city!), \(user!.state!)"
        self.aboutMeLabel.text = user!.userDescription
//        let sanity = user!.profilePicUrl
//        print("In displayinfo, profilePicUrl is : \(sanity)")
        
        // retrieve url from firebase
        ImageService.downloadImage(withURL: URL(string: user!.profilePicUrl)!) { image in
            self.profileImageView.image = image
        }
    }
}

extension ProfileVC {
    func helpFeedView() {
        setView(view: helpFeedContainer, hidden: false)
        setView(view: savedFeedContainer, hidden: true)
        setView(view: helperFeedContainer, hidden: true)
    }
    
    func helperFeedView() {
        setView(view: helpFeedContainer, hidden: true)
        setView(view: helperFeedContainer, hidden: false)
        setView(view: savedFeedContainer, hidden: true)
    }
    
    func savedFeedView() {
        setView(view: helpFeedContainer, hidden: true)
        setView(view: helperFeedContainer, hidden: true)
        setView(view: savedFeedContainer, hidden: false)
    }
    
    func initializeProfilePhotoElements() {
        // initialize imagePicker
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        // format profile image display
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
    }
    
    func setSegmentedControlView() {
        if (user == nil) {
            // if user is nil, then use publicCurrentUser
            user = publicCurrentUser
            segmentedControlWithSaved.isHidden = false
            segmentedControlWithoutSaved.isHidden = true
        } else if user?.safeEmail == publicCurrentUser?.safeEmail {
            // visiting user is the public user
            segmentedControlWithSaved.isHidden = false
            segmentedControlWithoutSaved.isHidden = true
        } else {
            // visiting user is not the public user
            segmentedControlWithSaved.isHidden = true
            segmentedControlWithoutSaved.isHidden = false
            settingsButton.isHidden = true
        }
    }
    
    // animation helper function to hide/show views
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
}
