//
//  LoginVC.swift
//  Able
//
//  Created by Andre Tran on 10/9/20.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class LoginVC: UIViewController, LoginButtonDelegate, GIDSignInDelegate  {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var displayError: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayError.textColor = .red
        
        // Check if user still signed in with Facebook
        if let token = AccessToken.current,
           !token.isExpired {
            goHomeScreen()
        }
        
        // Google login button
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        // Check if user still signed in with Google
        if GIDSignIn.sharedInstance()?.currentUser != nil {
            goHomeScreen()
        }
    }
    
    // Facebook button action
    @IBAction func facebookButtonAction(_ sender: Any) {
        let loginButton = FBLoginButton()
        loginButton.delegate = self
        loginButton.permissions = ["public_profile", "email"]
        
        // Hiding the button
        loginButton.isHidden = true
        view.addSubview(loginButton)
        
        // Simulating a tap for the actual Facebook SDK button
        loginButton.sendActions(for: UIControl.Event.touchUpInside)
    }
    
    // Facebook login action
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        if AccessToken.current == nil{
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Facebook authentication with Firebase error: ", error)
                return
            }
            print("Login success!")
            self.goHomeScreen()
        }
    }
    
    //Facebook logout action
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Logged out")
    }
    
    // Google login button action
    @IBAction func googleSignInPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    // Google login action
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let auth = user.authentication else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        Auth.auth().signIn(with: credentials) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Login Successful.")
                self.goHomeScreen()
            }
        }
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
            }
        }
    }
    
    // Helper function to display login error messages
    func displayMessage(text: String, color: UIColor){
        self.displayError.textColor = color
        self.displayError.text = text
    }
    
    // Go to home screen after successful login
    func goHomeScreen(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomePageVC")
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
    
}
