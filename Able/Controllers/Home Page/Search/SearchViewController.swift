//
//  SearchViewController.swift
//  Able
//
//  Created by Tim Nguyen on 10/30/20.
//  Fully Implemented by Ban-Jian Pan
//

import UIKit
import Firebase

class SearchViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchPostsView: UIView!
    @IBOutlet weak var searchUsersView: UIView!
    @IBOutlet weak var searchbarEditText: UISearchBar!
    @IBOutlet weak var helpHelperSegCtrl: UISegmentedControl!
    
    let ref: DatabaseReference! = Database.database().reference()
    var searchUserVC: SearchUsersViewController!
    var searchPostVC: SearchPostsViewController!
    var post: Bool = true
    var help: Bool = true
    var userList:[AbleUser] = []
    var filteredUserList1:[AbleUser] = []
    var helpPostList:[Post] = []
    var filteredHelpPostList1:[Post] = []
    var helperPostList:[Post] = []
    var filteredHelperPostList1:[Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView(view: searchPostsView, hidden: false)
        setView(view: searchUsersView, hidden: true)
        searchbarEditText.delegate = self
        fetchUsers()
        fetchPosts(type: "helpPosts")
        fetchPosts(type: "helperPosts")
    }
    
    func fetchUsers(){
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
    
    func fetchPosts(type: String) {
        let helperPostsRef = Database.database().reference().child("posts").child(type)
        
        helperPostsRef.observe(.value, with: { snapshot in
            
            var tempPosts = [Post]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let userKey = dict["userKey"] as? String,
                   let authorName = dict["authorName"] as? String,
                   let location = dict["location"] as? String,
                   let tags = dict["tags"] as? [String],
                   let text = dict["text"] as? String,
                   let timestamp = dict["timestamp"] as? Double,
                   dict["completed"] as? Bool == false {
                    
                    var numComments = 0
                    if let anyComments = dict["comments"] as? [String: Any] {
                        numComments = anyComments.count
                    }
                    let post = Post(id: childSnapshot.key, userKey: userKey, authorName: authorName, location: location, tags: tags, text: text, timestamp: timestamp, numComments: numComments)
                    if(type == "helpPosts"){
                        post.whichFeed = "helpPosts"
                    }else if(type == "helperPosts"){
                        post.whichFeed = "helperPosts"
                    }
                    post.completed = false
                    if let imageURL = dict["image"] as? String {
                        post.image = imageURL
                    }
                    tempPosts.append(post)
                }
            }
            if(type == "helpPosts"){
                self.helpPostList = tempPosts
            }else if(type == "helperPosts"){
                self.helperPostList = tempPosts
            }
            
        })
    }
    
    @IBAction func switchSearchViews(_ sender: UISegmentedControl) {
        //0 is post
        //1 is user
        if sender.selectedSegmentIndex == 0 {
            setView(view: searchPostsView, hidden: false)
            setView(view: searchUsersView, hidden: true)
            post = true
            helpHelperSegCtrl.isHidden = false
        }
        else if(sender.selectedSegmentIndex == 1){
            setView(view: searchPostsView, hidden: true)
            setView(view: searchUsersView, hidden: false)
            post = false
            helpHelperSegCtrl.isHidden = true
        }
//        print("post is: \(post)")
    }
    
    @IBAction func helpHelperSegmentView(_ sender: UISegmentedControl){
        //0 is help
        //1 is helper
        if(sender.selectedSegmentIndex == 0){
            //help
//            print("help")
            help = true
            searchPostVC.help1 = true
            searchPostVC.filteredPostList = filteredHelpPostList1
        
        }else if(sender.selectedSegmentIndex == 1){
            //helper
//            print("helper")
            help = false
            searchPostVC.help1 = false
            searchPostVC.filteredPostList = filteredHelperPostList1
        }
        searchPostVC.updateTableView()
    }
    
    // animation helper function to hide/show views
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredUserList1 = []
        filteredHelpPostList1 = []
        filteredHelperPostList1 = []
        
        for user in userList{
            let fullName = "\(user.firstName!) \(user.lastName!)"
            if(fullName.lowercased().contains(searchText.lowercased()) || user.username!.lowercased().contains(searchText.lowercased())){
                filteredUserList1.append(user)
            }
        }
        
        for helperPost in helperPostList{
            let postText = helperPost.text.lowercased()
            if(postText.contains(searchText.lowercased())){
                filteredHelperPostList1.append(helperPost)
            }
        }
        
        for helpPost in helpPostList{
            let postText = helpPost.text.lowercased()
            if(postText.contains(searchText.lowercased())){
                filteredHelpPostList1.append(helpPost)
            }
        }
        
        searchUserVC.filteredUserList = filteredUserList1
        searchUserVC.updateTableView()
        if(help){
            searchPostVC.filteredPostList = filteredHelpPostList1
        }else{
            searchPostVC.filteredPostList = filteredHelperPostList1
        }
        searchPostVC.updateTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "searchUserSegue"){
//            print("did user segue")
            self.searchUserVC = segue.destination as? SearchUsersViewController
        }else if(segue.identifier == "searchPostSegue"){
//            print("did post segue")
            self.searchPostVC = segue.destination as? SearchPostsViewController
        }
    }
    
    // This closes the keyboard when touch is detected outside of the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
