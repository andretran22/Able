//
//  SearchPostsViewController.swift
//  Able
//
//  Created by Tim Nguyen on 10/30/20.
//

import UIKit
import Firebase
import Foundation

class SearchPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditPost {
    
    @IBOutlet weak var postsTableView: UITableView!
    public var filteredPostList:[Post] = []
    public var help1 = true
    let postsCellIdentifier = "PostCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsTableView.delegate = self
        postsTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPostList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: postsCellIdentifier, for: indexPath as IndexPath) as! PostCell
        cell.post = filteredPostList[indexPath.row]
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //this function gets executed when you tap a row
        tableView.deselectRow(at: indexPath, animated: true)
        let post = filteredPostList[indexPath.row]
        self.performSegue(withIdentifier: "searchPostToPost", sender: post)
    }
    
    public func updateTableView(){
        postsTableView.reloadData()
    }
    
    func editPost(post: Post) {
        self.performSegue(withIdentifier: "ToEditPostSegueIdentifier", sender: post)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchPostToPost",
            let postPage = segue.destination as? PostViewController {
            let post = sender as! Post
            postPage.post = post
            if(help1){
                postPage.whichFeed = "helpPosts"
            }else{
                postPage.whichFeed = "helperPosts"
            }
        } else if segue.identifier == "ToEditPostSegueIdentifier",
                  let editPostVC = segue.destination as? CreatePostVC {
            let post = sender as! Post
            editPostVC.post = post
        }
    }
    
}
