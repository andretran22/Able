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
    
    var ref: DatabaseReference!
    var imagePicker: UIImagePickerController!
    
    // use this variable once we set up the segues
    var passedInUid = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup imagePicker to change the profile image
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        // TODO: change this once segues properly set up
        guard let uid = Auth.auth().currentUser?.uid else { return }
        displayInfo(uid: uid)
        setRating(uid: uid)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO: change this once segues properly set up
        guard let uid = Auth.auth().currentUser?.uid else { return }
        displayInfo(uid: uid)
        setRating(uid: uid)
    }
    
    // button that changes the aboutMeLabel text when the aboutMeButton is pressed
    @IBAction func editAboutMe(_ sender: Any) {
        let controller = UIAlertController(title: "Alert Controller",
                                           message: "Edit About Me",
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
        
        ref.child("user").child(uid).child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
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
    
    // get user data from Firebase realtime Database and display on screen
    // TODO: implement displaying other people's profiles
    func displayInfo(uid: String) {
        ref = Database.database().reference()
       
        ref.child("user").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let getData = snapshot.value as? [String:Any] {
                let username = getData["username"] as? String
                let city = getData["city"] as? String
                let state = getData["state"] as? String
                self.nameLabel.text = username
                self.locationLabel.text = "\(city ?? ""), \(state ?? "")"
            }
          }) { (error) in
            print(error.localizedDescription)
        }
    }
    
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
