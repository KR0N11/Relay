//
//  Candidate.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//
import Foundation

struct Candidate: Identifiable {
    
    let id: String
    var name: String
    var phone: String
    var resumeURL: String
    var coverLetterURL: String
    
    //Creates a Candidate FROM a Firestore dictionary
    init(id: String, dictionary: [String: Any]) {
        self.id = id
        self.name = dictionary["name"] as? String ?? ""
        self.phone = dictionary["phone"] as? String ?? ""
        self.resumeURL = dictionary["resumeURL"] as? String ?? ""
        self.coverLetterURL = dictionary["coverLetterURL"] as? String ?? ""
    }
    
    //initializer for when we first create a candidate
    init(id: String, name: String) {
        self.id = id
        self.name = name
        self.phone = ""
        self.resumeURL = ""
        self.coverLetterURL = ""
    }
    
    //Computed Property:
    var dictionary: [String: Any] {
        return [
            "name": name,
            "phone": phone,
            "resumeURL": resumeURL,
            "coverLetterURL": coverLetterURL
        ]
    }
}
