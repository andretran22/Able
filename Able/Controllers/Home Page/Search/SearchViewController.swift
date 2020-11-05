//
//  SearchViewController.swift
//  Able
//
//  Created by Tim Nguyen on 10/30/20.
//

import UIKit
import Firebase

class User1{
    var photoURL = ""
    var firstName = ""
    var lastName = ""
    var username = ""
    
    init(url: String, first: String, last: String, un: String){
        photoURL = url
        firstName = first
        lastName = last
        username = un
    }
    
}

class SearchViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchPostsView: UIView!
    @IBOutlet weak var searchUsersView: UIView!
    @IBOutlet weak var searchbarEditText: UISearchBar!
    let ref: DatabaseReference! = Database.database().reference()
    var searchUserVC: SearchUsersViewController!
    var searchPostVC: SearchPostsViewController!
    var userList:[User1] = []
    var filteredUserList1:[User1] = []
    
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
                   let dict = childSnapshot.value as? [String:Any],
                   let firstName1 = dict["first_name"] as? String,
                   let lastName1 = dict["last_name"] as? String,
                   let profPic = dict["photoURL"] as? String,
                   let username = dict["user_name"] as? String{
                    
                    let newUser = User1(url: profPic, first: firstName1, last: lastName1, un: username)
                    self.userList.append(newUser)
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
            let fullName = "\(user.firstName) \(user.lastName)"
            if(fullName.lowercased().contains(searchText.lowercased()) || user.username.lowercased().contains(searchText.lowercased())){
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
}
