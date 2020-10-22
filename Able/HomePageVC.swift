//
//  HomePageVC.swift
//  Able
//
//  Created by Andre Tran on 10/10/20.
//

import UIKit
import Firebase

class HomePageVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    // tapped on logout button
    @IBAction func logoutAction(_ sender: Any) {
        
        do {
            //log out Firebase session
            try FirebaseAuth.Auth.auth().signOut()
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginMainVC")
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated:true, completion:nil)
            
        } catch  {
            print("failed to logout")
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
