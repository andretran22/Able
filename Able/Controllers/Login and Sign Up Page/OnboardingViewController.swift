//
//  OnboardingViewController.swift
//  Able
//
//  Created by Andre Tran on 10/29/20.
//

import UIKit

class OnboardingViewController: UIViewController{
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var displayError: UILabel!
        
    var email:String!
    var firstname:String!
    var lastname:String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // continue to home page after entering additional info
    @IBAction func continueButton(_ sender: Any) {
        guard let username = usernameField.text, !username.isEmpty else {
            displayMessage(text: "Please enter a username")
            return
        }
        guard let city = cityField.text, !city.isEmpty else {
            displayMessage(text: "Please enter a city")
            return
        }
        guard let state = stateField.text, !state.isEmpty else {
            displayMessage(text: "Please enter a state")
            return
        }
        
        checkUniqueUsername(username: username, city: city, state: state)
        
    }
    
    //check if username exists
    func checkUniqueUsername(username:String, city:String, state:String){
        DatabaseManager.shared.usernameTaken(with: username) { exists in
            if !exists{
                self.insertToDatabase(username:username, city:city, state:state)
                self.goToHome()
            } else {
                self.displayMessage(text: "This username is taken, enter a different one")
            }
        }
    }
    
   
    
    
    // insert into database once we have all the necessary info
    func insertToDatabase(username:String, city:String, state:String){
        let newUser = AbleUser( firstName: firstname,
                                lastName: lastname,
                                emailAddress: email,
                                username: username,
                                city: city,
                                state: state)
        DatabaseManager.shared.insertUser(with: newUser)
    }
    
    // go to home page
    func goToHome() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "HomePage", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomePageVC")
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    // display sign up error messages
    func displayMessage(text: String){
        self.displayError.textColor = .red
        self.displayError.text = text
    }
}
