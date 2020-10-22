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
        
        Auth.auth().addStateDidChangeListener() {
          auth, user in

          if user != nil {
            print("logged in")
          }else{
            print("logged out")
          }
        }
    }
    

    @IBAction func settingButtonPressed(_ sender: Any) {
        
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
