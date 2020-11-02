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
        
        // Setup imagePicker to change the profile image
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
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
        // check that current user is authorized to change picture
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if passedInUid != uid { return }
        
        guard let image = profileImageView.image else { return }
        
        self.present(imagePicker, animated: true, completion: nil)
        self.uploadProfileImage(image) {url in
            if url != nil {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self.nameLabel.text
                changeRequest?.photoURL = url
                
                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User name changed")
                        self.saveProfile(username: self.nameLabel.text!, profileImageURL: url!) { success in
                            if success {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    } else {
                        print("Error: \(error!.localizedDescription)")
                    }
                }
            } else {
                // url is nil
            }
        }
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
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImageView.image = pickedImage
        }
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
    
    func displayInfo() {
        self.nameLabel.text = "\(user!.firstName!) \(user!.lastName!)"
        self.locationLabel.text = "\(user!.city!), \(user!.state!)"
        self.aboutMeLabel.text = user!.userDescription
    }
    
//    // get user data from Firebase realtime Database and display on screen
//    // TODO: implement displaying other people's profiles
//    func displayInfo(uid: String) {
//        ref = Database.database().reference()
//
//        ref.child("user").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
//            if let getData = snapshot.value as? [String:Any] {
//                let name = getData["name"] as? String
//                let city = getData["city"] as? String
//                let state = getData["state"] as? String
//                self.nameLabel.text = name
//                self.locationLabel.text = "\(city ?? ""), \(state ?? "")"
//            }
//          }) { (error) in
//            print(error.localizedDescription)
//        }
//    }
    
    // helper for changeProfileImage to put uploaded image to Firebase Storage
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url: URL?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/profile/\(uid)")
        let userObject = [
            "username:": username,
            "photoURL": profileImageURL.absoluteString
        ] as [String:Any]
        
        databaseRef.setValue(userObject) { (error, ref) in
            completion(error == nil)
        }
    }
}
