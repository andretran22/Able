//
//  SearchViewController.swift
//  Able
//
//  Created by Tim Nguyen on 10/30/20.
//

import UIKit
import Firebase

class SearchViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchPostsView: UIView!
    @IBOutlet weak var searchUsersView: UIView!
    @IBOutlet weak var searchbarEditText: UISearchBar!
    
    let ref: DatabaseReference! = Database.database().reference()
    var searchUserVC: SearchUsersViewController!
    var searchPostVC: SearchPostsViewController!
    var userList:[AbleUser] = []
    var filteredUserList1:[AbleUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView(view: searchPostsView, hidden: false)
        setView(view: searchUsersView, hidden: true)
        searchbarEditText.delegate = self
        //get all the users and put them in the userList
        let getUsers = ref.child("users")
        getUsers.observe(.value, with: {snapshot in
            for child in snapshot.children{
                
                if let childSnapshot = child as? DataSnapshot,
                   let userData = childSnapshot.value as? [String:Any],
                   let firstName = userData["first_name"] as? String,
                   let lastName = userData["last_name"] as? String,
                   let username = userData["user_name"] as? String,
                   let city = userData["city"] as? String,
                   let state = userData["state"] as? String,
                   let url = userData["photoURL"] as? String,
                   let user_description = userData["user_description"] as? String {

                    let user = AbleUser(firstName: firstName, lastName: lastName,
                                        emailAddress: childSnapshot.key, username: username, city: city, state: state, profilePicURL: url, userDescription: user_description)
                    self.userList.append(user)
                }
            }
        })
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("change in search bar")
        filteredUserList1 = []
        print("before \(searchUserVC.filteredUserList.count)")
        for user in userList{
            let fullName = "\(user.firstName!) \(user.lastName!)"
            if(fullName.lowercased().contains(searchText.lowercased()) || user.username!.lowercased().contains(searchText.lowercased())){
                filteredUserList1.append(user)
            }
        }
        searchUserVC.filteredUserList = filteredUserList1
        print("after \(searchUserVC.filteredUserList.count)")
        searchUserVC.updateTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "searchUserSegue"){
            print("did user segue")
            self.searchUserVC = segue.destination as? SearchUsersViewController
        }else if(segue.identifier == "searchPostSegue"){
            print("did post segue")
            self.searchPostVC = segue.destination as? SearchPostsViewController
        }
    }
    
    // This closes the keyboard when touch is detected outside of the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
