//
//  SettingsViewController.swift
//  Able
//
//  Created by XCodeClub on 2020-10-16.
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
    var savedPosts = [Post]()
    var helperPosts = [Post]()
    var helpPosts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        print("inside setting")
        ref.child("users/\(publicCurrentUser!.safeEmail)").observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            print(value!.count)

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
        print("inside update info")
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
