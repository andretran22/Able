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
    
    
    var ref: DatabaseReference!
    var imagePicker: UIImagePickerController!
    
    // use this variable once we set up the segues
    var passedInUid = String()
    
    // user's profile
    var user: AbleUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView(view: helpFeedContainer, hidden: false)
        setView(view: helperFeedContainer, hidden: true)
        
        // Setup imagePicker to change the profile image
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        
        // if user is nil, then use publicCurrentUser
        if (user == nil) {
            user = publicCurrentUser
        }
//        print("CURRENTLY VIEWING THIS USER PROFILE")
//        user?.printInfo()
//        print("THIS USER IS VIEWING THIS PROFILE")
//        publicCurrentUser?.printInfo()

        displayInfo()
        setRating(uid: user!.safeEmail)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayInfo()
        setRating(uid: user!.safeEmail)
    }
    
    @IBAction func switchViews(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            setView(view: helpFeedContainer, hidden: false)
            setView(view: helperFeedContainer, hidden: true)
            print("In helperFeedContainer")
        }
        else{
            setView(view: helpFeedContainer, hidden: true)
            setView(view: helperFeedContainer, hidden: false)
            print("In helpFeedContainer")
        }
    }
    // animation helper function to hide/show views
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
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
        print("hit changeProfileImage")
        present(imagePicker, animated: true)
//
        
//        // check that current user is authorized to change picture
//        if user?.safeEmail != publicCurrentUser?.safeEmail { return }
//        guard let uid = user?.safeEmail else { return }
//
//        self.present(imagePicker, animated: true, completion: nil)
//        guard let image = profileImageView.image else { return }
//        self.uploadProfileImage(image) {url in
//            if url != nil {
//                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
//                changeRequest?.displayName = self.nameLabel.text
//                changeRequest?.photoURL = url
//
//                changeRequest?.commitChanges { error in
//                    if error == nil {
//                        print("User name changed")
//                        self.saveProfile(username: uid, profileImageURL: url!) { success in
//                            if success {
//                                self.navigationController?.popViewController(animated: true)
//                            }
//                        }
//                    } else {
//                        print("Error: \(error!.localizedDescription)")
//                    }
//                }
//            } else {
//                // url is nil
//            }
//        }
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
        
        if segue.identifier == "reviewSegue",
           let profilePageVC = segue.destination as? ReviewVC {
           profilePageVC.viewUser = user
       }
    }
}

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        profileImageView.image = image
        
        guard let uid = user?.safeEmail else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metaData, completion: { _, error in
            guard error == nil else {
                print("Failed to upload")
                return
            }
            
            storageRef.downloadURL(completion: {url, error in
                guard let url = url, error == nil else {
                    return
                }
                
                let urlString = url.absoluteString
                print("downloadURL: \(urlString)")
                self.user?.profilePicUrl = urlString
            })
        })
//        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
//            self.profileImageView.image = pickedImage
//        }
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
        let sanity = user!.profilePicUrl
        print("In displayinfo, profilePicUrl is : \(sanity)")
        
        // retrieve url from firebase
        ImageService.downloadImage(withURL: URL(string: user!.profilePicUrl)!) { image in
            self.profileImageView.image = image
        }
    }
    
    // helper for changeProfileImage to put uploaded image to Firebase Storage
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url: URL?)->())) {
        guard let uid = user?.safeEmail else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil, metaData != nil {
                storageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        completion(nil)
                    }
                    if url != nil {
                        completion(url)
                    }
                })
            } else {
                completion(nil)
            }
        }
    }
    
    // helper for changeProfileImage to put image into specified user's storage url
    func saveProfile(username: String, profileImageURL: URL, completion: @escaping ((_ success:Bool)->())) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
        ref = Database.database().reference().child("users/\(username)")
        user?.profilePicUrl = profileImageURL.absoluteString
//        ref.observeSingleEvent(of: .value, with: {
//            (snapshot) in
//            self.ref.child("photoURL").setValue(profileImageURL.absoluteString)
//        }) { (error) in
////            completion(error == nil)
//        }
        ref.child("photoURL").setValue(profileImageURL.absoluteString) { (error, ref) in
            completion(error == nil)
        }
    }
}
