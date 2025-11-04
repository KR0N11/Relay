//
//  Recruiter.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//
import Foundation

struct Recruiter: Identifiable {
    
    let id: String
    var name: String
    var email: String
    var companyID: String

    //Initializer:
    init(id: String, dictionary: [String: Any]) {
        self.id = id
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.companyID = dictionary["companyID"] as? String ?? ""
    }
    
    init(id: String, name: String, email: String, companyID: String) {
        self.id = id
        self.name = name
        self.email = email
        self.companyID = companyID
    }
    
    //Computed Property
    var dictionary: [String: Any] {
        return [
            "name": name,
            "email": email,
            "companyID": companyID
        ]
    }
}

