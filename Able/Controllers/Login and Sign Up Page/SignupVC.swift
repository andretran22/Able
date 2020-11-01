//
//  SignupVC.swift
//  Able
//
//  Created by Andre Tran on 10/9/20.
//

import UIKit
import Firebase

class SignupVC: UIViewController {
    var ref: DatabaseReference!
    @IBOutlet weak var displayError: UILabel!
    
    @IBOutlet weak var lastnameField: UITextField!
    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        displayError.textColor = .red
        passwordField.textContentType = .oneTimeCode
        confirmPassField.textContentType = .oneTimeCode
    }
    
    // sign up with Firebase
    @IBAction func signUpButton(_ sender: Any) {
        if checkEmptyFields(){
            let email = emailField.text!
            let username = usernameField.text!
            let password = passwordField.text!
            
            //check if username taken
            DatabaseManager.shared.usernameTaken(with: username) { (exists) in
                if !exists { //username not taken
                    Auth.auth().createUser(withEmail: email, password: password) { [self] authResult, error in
                        if let error = error as NSError? {
                            displayMessage(text: "Error: \(error.localizedDescription)")
                        } else {
                            displayMessage(text: "Signed Up Successfully")
                            saveToDatabase()
                            publicCurrentUserEmail = email
                            goHomeScreen()
                        }
                    }
                }
                self.displayMessage(text: "Username is taken. Enter another.")
                return
            }
        }
    }
    
    //check for empty fields, matching password, and password length
    func checkEmptyFields() -> Bool{
        guard let first = firstnameField.text, !first.isEmpty else {
            displayMessage(text: "Please enter your firstname")
            return false
        }
        guard let last = lastnameField.text, !last.isEmpty else {
            displayMessage(text: "Please enter your lastname")
            return false
        }
        guard let user = usernameField.text, !user.isEmpty else {
            displayMessage(text: "Please enter a username")
            return false
        }
        guard let mail = emailField.text, !mail.isEmpty else {
            displayMessage(text: "Please enter an email")
            return false
        }
        guard let pass = passwordField.text, !pass.isEmpty else {
            displayMessage(text: "Please enter a password")
            return false
        }
        guard pass.count == 6 else {
            displayMessage(text: "Password must contain 6 characters or longer")
            return false
        }
        guard let confPass = confirmPassField.text, !confPass.isEmpty else {
            displayMessage(text: "Please confirm password")
            return false
        }
        guard pass == confPass else {
            displayMessage(text: "Passwords do not match")
            return false
        }
        guard let city = cityField.text, !city.isEmpty else {
            displayMessage(text: "Please enter a city")
            return false
        }
        guard let state = stateField.text, !state.isEmpty else {
            displayMessage(text: "Please enter a state")
            return false
        }
        
        return true
    }
    
    // display sign up error messages
    func displayMessage(text: String){
        self.displayError.textColor = .red
        self.displayError.text = text
    }
    
    // go to home screen after successful sign up
    func goHomeScreen(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "HomePage", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomePageVC")
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    // save information to Firebase
//    func saveInfo() {
//        ref = Database.database().reference()
//        let newUser = ref.child("user").child(emailField.text!)
//        newUser.child("reviews").child("numReviews").setValue(0)
//    }
//
    func saveToDatabase() {
        DatabaseManager.shared.insertUser(with: AbleUser(
            firstName: firstnameField.text!,
            lastName: lastnameField.text!,
            emailAddress: emailField.text!,
            username: usernameField.text!,
            city: cityField.text!,
            state: stateField.text!
        )
        )
    }
    // This closes the keyboard when touch is detected outside of the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
}
