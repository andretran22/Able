//
//  SignupVC.swift
//  Able
//
//  Created by Andre Tran on 10/9/20.
//

import UIKit
import Firebase

class SignupVC: UITableViewController, ChangeLocation{
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var displayError: UILabel!
    @IBOutlet weak var lastnameField: UITextField!
    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!
    @IBOutlet weak var locationButton: UIButton!
    var location:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayError.textColor = .red
        passwordField.textContentType = .oneTimeCode
        confirmPassField.textContentType = .oneTimeCode
        displayError.isHidden = false
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        clearFields()
//    }
    
    func clearFields() {
        lastnameField.text = ""
        firstnameField.text = ""
        usernameField.text = ""
        emailField.text = ""
        passwordField.text = ""
        confirmPassField.text = ""
        displayError.text = ""
        displayError.isHidden = true
        location = ""
        locationButton.setTitle("Choose a Location", for: .normal)
    }
    
    // segue to location view controller to select list of default locations
    @IBAction func locationButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "goToLocation", sender: self)
    }
    
    //change location protocol stub
    func changeLocation(location: String) {
        displayMessage(text: "")
        self.location = location
        self.locationButton.setTitle(location, for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToLocation",
           let locationVC = segue.destination as? LocationViewController{
            locationVC.delegate = self
        }
    }
    
    // sign up with Firebase
    @IBAction func signUpButton(_ sender: Any) {
        if checkEmptyFields(){
            let email = emailField.text!
            let username = usernameField.text!
            let password = passwordField.text!
            
            //check if username taken
            DatabaseManager.shared.usernameTaken(with: username) { (exists) in
                print("hey: \(username)")
                if !exists { //username not taken
                    
                    self.displayMessage(text: "")
                    Auth.auth().createUser(withEmail: email, password: password) { [self] authResult, error in
                        if let error = error as NSError? {
                            displayMessage(text: "Error: \(error.localizedDescription)")
                        } else {
                            saveToDatabase()
                            publicCurrentUserEmail = email
                            goHomeScreen()
                        }
                    }
                }else{
                    self.displayMessage(text: "Username is taken. Enter another.")
                    return
                }
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
        guard pass.count >= 6 else {
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
        guard location != "" else {
            displayMessage(text: "Please choose a location")
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
        clearFields()
        let storyBoard: UIStoryboard = UIStoryboard(name: "HomePage", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomePageVC")
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func saveToDatabase() {
        
        let separators = CharacterSet(charactersIn: ",")
        var locationQuery = location.components(separatedBy: separators)
        
        //remove any elements that are just spaces
        locationQuery.removeAll { $0 == "" }
        
        //removes leading/trailing spaces in the U.S State, not middle spaces
        locationQuery[1] = locationQuery[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        let cityLocation = locationQuery[0]
        let stateLocation = locationQuery[1]
        
        DatabaseManager.shared.insertUser(with: AbleUser(
            firstName: firstnameField.text!,
            lastName: lastnameField.text!,
            emailAddress: emailField.text!,
            username: usernameField.text!,
            city: cityLocation,
            state: stateLocation,
            profilePicURL: defaultProfilePicURL
        )
        )
    }
    
    
    @IBAction func done (sender: UITextField){
        sender.resignFirstResponder()
    }
    // This closes the keyboard when touch is detected outside of the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
}
