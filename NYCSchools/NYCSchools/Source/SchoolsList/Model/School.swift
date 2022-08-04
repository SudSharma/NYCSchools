//
//  School.swift
//  NYCSchools
//
//  Created by Sudarshan Sharma on 8/3/22.
//

struct School: Codable, Hashable {
    
    // District Borough Number
    let dbn: String!
    
    // Address fields
    var primary_address_line_1: String?
    var city: String?
    var zip: String?
    var state_code: String?
    
    // Location
    var latitude: String?
    var longitude: String?
    
    // School Contacts
    var phone_number: String?
    var school_email: String?
    var website: String?
    
    let school_name: String
}

