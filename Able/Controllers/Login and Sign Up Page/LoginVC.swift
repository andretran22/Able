//
//  LoginVC.swift
//  Able
//
//  Created by Andre Tran on 10/9/20.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit



class LoginVC: UIViewController, LoginButtonDelegate, GIDSignInDelegate  {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var displayError: UILabel!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        displayError.textColor = .red
        facebookButton.setImage(UIImage(named: "fb-logo"), for: .normal)
        facebookButton.tintColor = .black
        
        googleButton.setImage(UIImage(named: "google-logo"), for: .normal)
        googleButton.tintColor = .black
        
        // Check if user still signed in with Facebook
        if AccessToken.isCurrentAccessTokenActive{
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
        FBSDKLoginKit.LoginManager().logOut()
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
            
            // Get email and name from Facebook using Graph Request API
            let requestedFields = "email, first_name, last_name"
            GraphRequest.init(graphPath: "me", parameters: ["fields":requestedFields]).start { (connection, result, error) -> Void in
                if error != nil {
                    NSLog(error.debugDescription)
                    return
                }
                
                // getting email and name from fb to store and pass
                guard let result = result as? [String:String] else {
                    print("result incorrect format")
                    return
                }
                guard let email: String = result["email"] else {
                    print("Cannot retrieve email from Facebook")
                    return
                }
                guard let firstName: String = result["first_name"] else {
                    print("Cannot retrieve firstname from Facebook")
                    return
                }
                guard let lastName: String = result["last_name"] else {
                    print("Cannot retrieve lastname from Facebook")
                    return
                }
                
                // add facebook user to database if not already.
                self.checkInDatabase(for: email, firstname: firstName, lastname: lastName)
            }
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
                guard let email = user.profile.email,
                      let firstname = user.profile.givenName,
                      let lastname = user.profile.familyName else {
                    return
                }
                self.checkInDatabase(for: email, firstname: firstname, lastname: lastname)
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
                publicCurrentUserEmail = email
                goHomeScreen()
            }
        }
    }
    
    // check if user exists in database already. If not, take them to onboarding to fill out more info
    func checkInDatabase(for email:String, firstname:String, lastname:String) {
        publicCurrentUserEmail = email
        DatabaseManager.shared.userExists(with: email) { exists in
            if !exists{
                let info = ["email": email, "first": firstname, "last": lastname]
                self.performSegue(withIdentifier: "segueToOnboard", sender: info)
            } else {
                self.goHomeScreen()
            }
        }
    }

    
    // Helper function to display login error messages
    func displayMessage(text: String, color: UIColor){
        self.displayError.textColor = color
        self.displayError.text = text
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToOnboard",
           let nextVC = segue.destination as? OnboardingViewController,
           let info = sender as? Dictionary<String, String> {
            nextVC.email = info["email"]
            nextVC.firstname = info["first"]
            nextVC.lastname = info["last"]
        }
        print("segueing...")
    }
    
    
    // Go to home screen after successful login
    func goHomeScreen(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "HomePage", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomePageVC")
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    
    // This closes the keyboard when touch is detected outside of the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

