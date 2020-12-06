//
//  SettingsViewController.swift
//  Able
//
//  Created by Ban-Jian Pan on 2020-10-16.
//  Fully Implemented by Ban-Jian Pan
//

import UIKit
import Firebase
import FirebaseDatabase
import FBSDKLoginKit
import GoogleSignIn

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var usernameEditText: UITextField!
    @IBOutlet weak var firstNameEditText: UITextField!
    @IBOutlet weak var lastNameEditText: UITextField!
    @IBOutlet weak var cityEditText: UITextField!
    @IBOutlet weak var stateEditText: UITextField!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    
    let ref: DatabaseReference! = Database.database().reference()
    let uid: String = Auth.auth().currentUser!.uid
    var username = ""
    var firstName = ""
    var lastName = ""
    var notifcations = false
    var city = ""
    var state = ""
    
    // use this to retrieve the current user's saved posts (see SavedFeedVC for reference)
    var viewUser: AbleUser?
    var userEmail = ""
    
    var savedPosts = [Post]()
    var helperPosts = [Post]()
    var helpPosts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
//        print("inside setting")
        userEmail = viewUser!.safeEmail
//        print(userEmail)
        //----------------------------------------------------------------------
        ref.child("users/\(publicCurrentUser!.safeEmail)").observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
//            print(value!.count)

            self.username = value!["user_name"] as! String
            self.firstName = value!["first_name"] as! String
            self.lastName = value!["last_name"] as! String
            // TODO: Need to change this
            // self.notifcations = value!["notifications"] as! Bool

            self.city = value!["city"] as! String
            self.state = value!["state"] as! String
            self.usernameEditText.text = self.username
            self.firstNameEditText.text = self.firstName
            self.lastNameEditText.text = self.lastName
            self.cityEditText.text = self.city
            self.stateEditText.text = self.state
        })
        
//        ref.child("posts/helpPosts").observeSingleEvent(of: .value, with: {(snapshot) in
//            let value = snapshot.value as? NSDictionary
//            for posts in value!{
//
//            }
//
//        })
        
//        for count in 0...5 {
//            print(count)
//        }
//        print("count of help posts: ")
        
    }
    
    func deleteSavedPost(folderKey: String){
        self.ref.child("users").observeSingleEvent(of: .value) { snapshot in
            for user in snapshot.children{
                if let user1 = user as? DataSnapshot,
                let dict = user1.value as? [String:Any],
                let userKey = dict["saved_posts"] as? [String:Any]
                {
                    let safeEmail = user1.key
//                    print(safeEmail)
                    for posts in userKey{
                        //goes through all the saved_posts and deletes them if they match the parameter "folderKey"
                        let postKey = posts.key
//                        print(posts.key)
                        if(postKey == folderKey){
                            let deleteRef = self.ref.child("users/\(safeEmail)/saved_posts/\(folderKey)")
                            deleteRef.removeValue()
                        }
                        
                    }
                }
            }
        }
    }
    
    

    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        
        
        let controller = UIAlertController(title: "Delete account",
                                           message: "Are you sure you want to delete your account?\nThis action cannot be undone.",
                                           preferredStyle: .actionSheet)
        
        //change this to handle deleting firebase account 
        controller.addAction(UIAlertAction(title: "Delete account",
                                           style: .destructive,
                                           handler: {
                                            (action) in
                                            //put delete post and comment function here
                                            //deletes all the helper posts this user may have as well as if anyone saved this user's posts
                                            self.ref.child("posts/helperPosts").observeSingleEvent(of: .value) { snapshot in
                                                for posts in snapshot.children{
                                                    if let helperPosts = posts as? DataSnapshot,
                                                    let dict = helperPosts.value as? [String:Any]{
//                                                        print("for loop")
                                                        let folderKey = helperPosts.key
                                                        let userKey = dict["userKey"] as? String
                                                        if(userKey == self.userEmail){
//                                                            print("found it!")
                                                            let deleteRef = self.ref.child("posts/helperPosts/\(folderKey)")
                                                            deleteRef.removeValue()
                                                            self.deleteSavedPost(folderKey: folderKey)
                                                        }
                                                        
                                                    }
                                                }
                                            }
                                            //deletes all the help posts the user may have as well as if anyone saved this user's posts
                                            self.ref.child("posts/helpPosts").observeSingleEvent(of: .value) { snapshot in
                                                for posts in snapshot.children{
                                                    if let helpPosts = posts as? DataSnapshot,
                                                    let dict = helpPosts.value as? [String:Any]{
//                                                        print("for loop2")
                                                        let folderKey = helpPosts.key
                                                        let userKey = dict["userKey"] as? String
                                                        if(userKey == self.userEmail){
//                                                            print("found it!")
                                                            let deleteRef = self.ref.child("posts/helpPosts/\(folderKey)")
                                                            deleteRef.removeValue()
                                                            self.deleteSavedPost(folderKey: folderKey)
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            let user = Auth.auth().currentUser
                                            self.ref.child("users/\(publicCurrentUser!.safeEmail)").removeValue()
                                            user?.delete { error in
                                              if let error = error {
                                                // An error happened.
                                                print("error while trying to delete account")
                                              } else {
                                                // Account deleted.
                                                print("account deleted")
                                                self.dismiss(animated: true, completion: nil)
                                              }
                                            }
                                            
                                           }))
        
        controller.addAction(UIAlertAction(title: "Cancel",
                                           style: .cancel,
                                           handler: nil))
      
        
        present(controller, animated: true, completion: nil)
    }
    
    
   
    @IBAction func changePasswordButtonPressed(_ sender: Any) {
        
//        Auth.auth().currentUser.pas
        
//        print("printing stuff")
//        print(self.username)
//        print(self.password)
//        print(self.city)
//        print(self.state)
        
        let controller = UIAlertController(title: "Change Password",
                                           message: "",
                                           preferredStyle: .alert)
        
//        controller.addTextField(configurationHandler: nil)
        controller.addTextField(configurationHandler: {
            (textField:UITextField!) in textField.placeholder = "Enter Old Password"
        })
        controller.addTextField(configurationHandler: {
            (textField:UITextField!) in textField.placeholder = "Enter New Password"
        })
        controller.addTextField(configurationHandler: {
            (textField:UITextField!) in textField.placeholder = "Re-enter New Password"
        })
        
        //add functionality to change password in firebase
        controller.addAction(UIAlertAction(title: "Change Password",
                                           style: .default,
                                           handler: {
                                            (action) in
                                            if let textFieldArray = controller.textFields {
                                                
                                                let textFields = textFieldArray as [UITextField]
                                                let oldPassword = textFields[0].text
                                                let newPassword = textFields[1].text
                                                let newPasswordReEntered = textFields[2].text
                                                let user = Auth.auth().currentUser
                                                let credentials: AuthCredential = Firebase.EmailAuthProvider.credential(withEmail: user?.email as! String, password: oldPassword!)
                                                
                                                user?.reauthenticate(with: credentials) { (authResult, error) in
                                                  if let error = error {
                                                    // An error happened.
                                                    print("error \(error)")
                                                    print("Youre old password was wrong")
                                                  } else {
                                                    // User re-authenticated.
                                                    print("reauthenticated")
                                                    if(newPassword == newPasswordReEntered){
                                                        //perform change password on firebase
                                                        Auth.auth().currentUser?.updatePassword(to: newPassword!) { (error) in
                                                          print("error: \(error)")
                                                        }
                                                    }else{
                                                        print("new password do not match")
                                                    }
                                                  }
                                                }
                                                
                                            }}))
        
        controller.addAction(UIAlertAction(title: "Cancel",
                                           style: .cancel,
                                           handler: nil))
      
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        logoutUser()
        //LoginMainViewController
        //dismiss(animated: true, completion: nil)
    }
    
    func logoutUser() {
        //Logout Facebook
        FBSDKLoginKit.LoginManager().logOut()
        
        //logout Google
        GIDSignIn.sharedInstance()?.signOut()
        
        
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        }
        catch { print("already logged out") }
    }
    

    @IBAction func updateInformationButtonPressed(_ sender: Any) {
//        print("inside update info")
        ref.child("users/\(publicCurrentUser!.safeEmail)").updateChildValues([
            "user_name": usernameEditText.text!,
            "first_name": firstNameEditText.text!,
            "last_name": lastNameEditText.text!,
            "city": cityEditText.text!,
            "state": stateEditText.text!
        ])
        publicCurrentUser?.username = usernameEditText.text!
        publicCurrentUser?.firstName = firstNameEditText.text!
        publicCurrentUser?.lastName = lastNameEditText.text!
        publicCurrentUser?.city = cityEditText.text!
        publicCurrentUser?.state = stateEditText.text!
        
        viewUser?.username = usernameEditText.text!
        viewUser?.firstName = firstNameEditText.text!
        viewUser?.lastName = lastNameEditText.text!
        viewUser?.city = cityEditText.text!
        viewUser?.state = stateEditText.text!
        
        changeNameInPosts()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func notificationSwitchChanged(_ sender: Any) {
        if(notificationsSwitch.isOn){
            ref.child("users/\(publicCurrentUser!.safeEmail)").updateChildValues([
                "notifications": true
            ])
        }else{
            ref.child("users/\(publicCurrentUser!.safeEmail)").updateChildValues([
                "notifications": false
            ])
        }
    }
    
    // This closes the keyboard when touch is detected outside of the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

extension SettingsViewController {
    func changeNameInPosts() {
        viewUser = publicCurrentUser
        let newName = (viewUser?.firstName)! + " " + (viewUser?.lastName)!
        print("newName is \(newName)")
        // change name in help posts
        for post in helpPosts {
            let uid = post.id
            print("helpPost uid is \(uid)")
            
            Database.database().reference().child("posts/helpPosts/\(uid)/authorName").setValue(newName)
        }
        
        // change name in helper posts
        for post in helperPosts {
            let uid = post.id
            print("helperPost uid is \(uid)")
            
            Database.database().reference().child("posts/helperPosts/\(uid)/authorName").setValue(newName)
        }
    }
}
