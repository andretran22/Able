//
//  LoginVC.swift
//  Able
//
//  Created by Andre Tran on 10/9/20.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var displayError: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayError.textColor = .red
        
    }
    
    //login with Firebase
    @IBAction func loginButton(_ sender: Any) {
        let email = usernameField.text!
        let password = passwordField.text!
        Auth.auth().signIn(withEmail: email, password: password) { [self] (authResult, error) in
            if let error = error as NSError? {
                displayMessage(text: "Error: \(error.localizedDescription)", color: .red)
            } else {
                displayMessage(text: "Login Successful", color: .black)
                goHomeScreen()
                //dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // helper function to display login error messages
    func displayMessage(text: String, color: UIColor){
        self.displayError.textColor = color
        self.displayError.text = text
    }
    
    // go to home screen after successful login
    func goHomeScreen(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomePageVC")
        nextViewController.modalPresentationStyle = .fullScreen
        
        self.present(nextViewController, animated:true, completion:nil)
    }
    

}
