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

let defaultProfilePicURL = "https://firebasestorage.googleapis.com/v0/b/able-90d0e.appspot.com/o/empty%20profile.png?alt=media&token=977e093a-6b15-48da-b39a-d19c5ade82bf"

class AbleUser {
     var firstName: String?
     var lastName: String?
     var emailAddress: String?
     var username: String?
     var city: String?
     var state: String?
    var userDescription: String?
    // default profile pic in Database
    var profilePicUrl = defaultProfilePicURL
    
    // initial account creation with default user description
    init(firstName:String, lastName:String, emailAddress:String, username:String, city: String, state: String, profilePicURL: String){
        self.firstName = firstName
        self.lastName = lastName
        self.emailAddress = emailAddress
        self.username = username
        self.city = city
        self.state = state
        self.userDescription = "Hi, I'm " + firstName
        self.profilePicUrl = profilePicURL
    }
    
    // use this if the account has already been created
    init(firstName:String, lastName:String, emailAddress:String, username:String, city: String, state: String, profilePicURL: String, userDescription: String){
        self.firstName = firstName
        self.lastName = lastName
        self.emailAddress = emailAddress
        self.username = username
        self.city = city
        self.state = state
        self.userDescription = userDescription
        self.profilePicUrl = profilePicURL
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
