//
//  AbleUser.swift
//  Able
//
//  Created by Andre Tran on 10/30/20.
//

import Foundation

// global var tracks email of current user
var publicCurrentUserEmail: String?

//global var tracks all meta data for current user
var publicCurrentUser:AbleUser?

class AbleUser {
     var firstName: String?
     var lastName: String?
     var emailAddress: String?
     var username: String?
     var city: String?
     var state: String?
    var userDescription: String?
    //    let profilePicUrl: String
    
    init(firstName:String, lastName:String, emailAddress:String, username:String, city: String, state: String){
        self.firstName = firstName
        self.lastName = lastName
        self.emailAddress = emailAddress
        self.username = username
        self.city = city
        self.state = state
        self.userDescription = "Hi, I'm " + firstName
    }
    
    var safeEmail: String {
        var safeEmail = emailAddress?.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail?.replacingOccurrences(of: "@", with: "-")
        return safeEmail ?? "this email is nil"
    }
    
    func printInfo(){
        print("Name: \(firstName!) \(lastName!)")
        print("Email: \(emailAddress!)")
        print("Username: \(username!)")
        print("City: \(city!)")
        print("State: \(state!)")
        print("User Description: \(userDescription)")
    }
 
}
