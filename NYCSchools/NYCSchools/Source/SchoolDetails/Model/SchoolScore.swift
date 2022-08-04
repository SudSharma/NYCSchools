//
//  SchoolScore.swift
//  NYCSchools
//
//  Created by Sudarshan Sharma on 8/3/22.
//

struct SchoolScore: Codable, Hashable {
    var num_of_sat_test_takers: String?
    var sat_critical_reading_avg_score: String?
    var sat_math_avg_score: String?
    var sat_writing_avg_score: String?
    var school_name: String?
}
