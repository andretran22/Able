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
        
        database.child("usernames").child(username).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
             completion(true)
        })
    }
    
    /// Insert new user into the database
    public func insertUser(with user: AbleUser){
        database.child("users").child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
            "user_name": user.username,
            "city": user.city,
            "state": user.state
        ])
        
        database.child("usernames").child(user.username).setValue([
            "email": user.safeEmail
        ])
    }
}


struct AbleUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    let username: String
    let city: String
    let state: String
    //    let profilePicUrl: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}
