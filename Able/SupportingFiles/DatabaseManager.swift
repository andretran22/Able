//
//  DatabaseManager.swift
//  Able
//
//  Created by Andre Tran on 10/28/20.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}

// MARK: - Account Management

extension DatabaseManager {
    
    // check if user exists in realtime database
    /// passes false to completion handler to indicate user does NOT exist.
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child("users").child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
        
    }
    
    
    // check if username is taken in realtitme database
    /// passes false to completion handler to indicate username is NOT taken.
    public func usernameTaken(with username: String,
                              completion: @escaping ((Bool) -> Void)){
        
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            for email in snapshot.children{
                if let emailSnapshot = email as? DataSnapshot,
                   let dict = emailSnapshot.value as? [String:Any]{
                        let other_username = dict["user_name"] as? String
                        if other_username == username {
                            
                            print("damn, username taken: \(username)")
                            completion(true)
                            return
                        }
                }
            }
            print("nice, username not taken: \(username)")
            completion(false)
        }
    }
    
    /// Insert new user into the database
    public func insertUser(with user: AbleUser){
        database.child("users").child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
            "user_name": user.username,
            "city": user.city,
            "state": user.state,
            "user_description": user.userDescription,
            "photoURL" : user.profilePicUrl
        ])
        database.child("users").child(user.safeEmail).child("reviews").child("numReviews").setValue(0)
    }
    
    
    public func setPublicUser(){
        guard let email = publicCurrentUserEmail else {
            print("Public email not set")
            return
        }
        let safeE = DatabaseManager.safeEmail(emailAddress: email)
        database.child("users").child(safeE).observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any],
                  let firstname = dict["first_name"] as? String,
                  let lastname = dict["last_name"] as? String,
                  let username = dict["user_name"] as? String,
                  let city = dict["city"] as? String,
                  let url = dict["photoURL"] as? String,
                  let state = dict["state"] as? String else {
                print("Could not retrive user data from Firebase")
                return
            }

            publicCurrentUser = AbleUser(firstName: firstname,
                                          lastName: lastname,
                                          emailAddress: email,
                                          username: username,
                                          city: city,
                                          state: state,
                                          profilePicURL: url)
            publicCurrentUser?.printInfo()
        }
    }
}


//struct AbleUser {
//    let firstName: String
//    let lastName: String
//    let emailAddress: String
//    let username: String
//    let city: String
//    let state: String
//    //    let profilePicUrl: String
//    
//    var safeEmail: String {
//        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
//        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
//        return safeEmail
//    }
//    
//}
