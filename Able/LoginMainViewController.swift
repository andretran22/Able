//
//  LoginMainViewController.swift
//  Able
//
//  Created by Andre Tran on 10/9/20.
//

import UIKit

class LoginMainViewController: UIViewController {
    
    @IBOutlet weak var loginContainer: UIView!
    @IBOutlet weak var signupContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
 
    
    // toggle either login screen or signup screen
    @IBAction func switchViews(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            setView(view: loginContainer, hidden: false)
            setView(view: signupContainer, hidden: true)
        }
        else{
            setView(view: loginContainer, hidden: true)
            setView(view: signupContainer, hidden: false)
        }
    }
    
    
    // animation helper function to hide/show views
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    
    
}
