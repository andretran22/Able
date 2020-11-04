//
//  Post.swift
//  AbleHomePage
//
//  Created by Tim Nguyen on 10/20/20.
//

import UIKit

class Post
{
    // basic post info
    var id: String
    var userKey: String
    var authorName: String
    var location: String
    var text: String
    //    var images: [String]? PhotosURLS
    
    // for help posts and helper posts
    var tags: [String]?
    var comments: [String]?
    var createdAt: Date // timestamp
    
    // for reviews
    var rating: Double?
    // timestamp for helper
    
    // for help and helper posts
    init(id: String, userKey: String, authorName: String, location: String,
         tags: [String], text: String, timestamp: Double) {
        self.id = id
        self.userKey = userKey
        self.authorName = authorName
        self.location = location
        self.tags = tags
        self.text = text
        self.createdAt = Date(timeIntervalSince1970: timestamp / 1000)
//        self.comments = comments
    }
    
    // for review posts
    init(id: String, userKey: String, authorName: String, location: String,
         text: String, timestamp: Double, rating: Double) {
        self.id = id
        self.userKey = userKey
        self.authorName = authorName
        self.location = location
        self.text = text
        self.createdAt = Date(timeIntervalSince1970: timestamp / 1000)
        self.rating = rating
    }
    
   
}
