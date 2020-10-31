//
//  SearchViewController.swift
//  Able
//
//  Created by Tim Nguyen on 10/30/20.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchPostsView: UIView!
    @IBOutlet weak var searchUsersView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func switchSearchViews(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            setView(view: searchPostsView, hidden: false)
            setView(view: searchUsersView, hidden: true)
        }
        else{
            setView(view: searchPostsView, hidden: true)
            setView(view: searchUsersView, hidden: false)
        }
    }
    
    // animation helper function to hide/show views
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
}
