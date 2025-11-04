//
//  UserAccount.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//
import Foundation
import FirebaseFirestore

struct UserAccount: Identifiable {
    
    let id: String
    let email: String
    let name: String
    let userRole: UserRole
    var lastLoginAt: Date

    enum UserRole: String {
        case candidate
        case recruiter
    }
    
    //INITIALIZER 1
    init(id: String, email: String, name: String, userRole: UserRole) {
        self.id = id
        self.email = email
        self.name = name
        self.userRole = userRole
        self.lastLoginAt = Date() // Set current date on creation
    }
    
    //INITIALIZER 2

    init?(id: String, dictionary: [String: Any]) {
        guard let email = dictionary["email"] as? String,
              let name = dictionary["name"] as? String,
              let roleString = dictionary["userRole"] as? String,
              let role = UserRole(rawValue: roleString),
              let lastLoginTimestamp = dictionary["lastLoginAt"] as? Timestamp
        else {
            return nil
        }
        
        self.id = id
        self.email = email
        self.name = name
        self.userRole = role
        self.lastLoginAt = lastLoginTimestamp.dateValue()
    }
    
    // --- Computed Property
    var dictionary: [String: Any] {
        return [
            "email": email,
            "name": name,
            "userRole": userRole.rawValue,
            "lastLoginAt": Timestamp(date: lastLoginAt)
        ]
    }
}
