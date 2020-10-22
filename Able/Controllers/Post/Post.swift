//
//  Post.swift
//  AbleHomePage
//
//  Created by Tim Nguyen on 10/20/20.
//

import UIKit

var helpPosts = [Post]()
var helperPosts = [Post]()

struct Post
{
    var createdBy: User
    var timeAgo: String?
    var tags: [String]?
    var caption: String?
    var image: UIImage?
    var numberOfComments: Int?
    
    static func fetchHelpPosts() -> [Post]
    {
        return helpPosts
    }
    
    static func fetchHelperPosts() -> [Post]
    {        
        return helperPosts
    }
    
    static func addHelpPost(post: Post) {
        helpPosts.append(post)
    }
    
    static func addHelperPost(post: Post) {
        helperPosts.append(post)
    }
}

struct User
{
    var username: String?
    var profileImage: UIImage?
}
