//
//  NotificationClass.swift
//  Able
//
//  Created by Andre Tran on 12/6/20.
//

import Foundation

class NotificationObj {
    var commenterKey: String?
    var fullname: String?
    var pictureUrl: String?
    var postId: String?
    var timestamp: Date?
    var text: String?
    var type: String?
    
    init(commenterKey:String, fullname:String, pictureUrl:String, postId: String, timestamp:Double, text:String, type:String){
        self.commenterKey = commenterKey
        self.fullname = fullname
        self.pictureUrl = pictureUrl
        self.postId = postId
        self.timestamp =  Date(timeIntervalSince1970: timestamp / 1000)
        self.text = text
        self.type = type
    }
    
    func printInfo(){
        print("*** PRINTING NOTIFICATION OBJECT")
        print("Commenter Key: \(commenterKey ?? "err")")
        print("Fullname: \(fullname ?? "err")")
        print("Post Id: \(postId)")
        print("Timestamp: \(String(describing: timestamp))")
        print("Picture Url: \(pictureUrl ?? "err")")
        print("Text: \(text ?? "err")")
        print("Type: \(type ?? "err")")
        print("")
    }
    
}
