//
//  OnboardingViewController.swift
//  Able
//
//  Created by Andre Tran on 10/29/20.
//

import UIKit



class OnboardingViewController: UIViewController, ChangeLocation{
    
    @IBOutlet weak var usernameField: UITextField!
//    @IBOutlet weak var cityField: UITextField!
//    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var displayError: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    
    var email:String!
    var firstname:String!
    var lastname:String!
    var location:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //change location protocol stub
    func changeLocation(location: String) {
        displayMessage(text: "")
        self.location = location
        self.locationButton.setTitle(location, for: .normal)
    }
    
    // segue to locationVC to select a location
    @IBAction func locationActionButton(_ sender: Any) {
        performSegue(withIdentifier: "segueLocationVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueLocationVC",
           let locationVC = segue.destination as? LocationViewController {
            locationVC.delegate = self
        }
    }
    
    // continue to home page after entering additional info
    @IBAction func continueButton(_ sender: Any) {
        guard let username = usernameField.text, !username.isEmpty else {
            displayMessage(text: "Please enter a username")
            return
        }
        
        guard location != "" else {
            displayMessage(text: "Please choose a location")
            return
        }

        let separators = CharacterSet(charactersIn: ",")
        var locationQuery = location.components(separatedBy: separators)
        
        //remove any elements that are just spaces
        locationQuery.removeAll { $0 == "" }
        
        //removes leading/trailing spaces in the U.S State, not middle spaces
        locationQuery[1] = locationQuery[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        let cityLocation = locationQuery[0]
        let stateLocation = locationQuery[1]
        
        checkUniqueUsername(username: username, city: cityLocation, state: stateLocation)
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
                                state: state,
                                profilePicURL: defaultProfilePicURL)
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
