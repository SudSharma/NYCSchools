//
//  SchoolDetailsDataSource.swift
//  NYCSchools
//
//  Created by Sudarshan Sharma on 8/3/22.
//

import Combine
import Foundation

protocol SchoolDetailsDataSourceProtocol {
    func fetchSchoolScores(_ schoolDBN: String) -> AnyPublisher<[SchoolScore], Error>?
}

class SchoolDetailsDataSource {
    func fetchSchoolScores(_ schoolDBN: String) -> AnyPublisher<[SchoolScore], Error>? {
        let request = Request(Constants.schoolSATScoreURL,
                              queryParameters: [URLQueryItem(name: "dbn", value: schoolDBN)])
        return Networking().dataTaskPublisher(for: request, type: [SchoolScore].self)?
            .eraseToAnyPublisher()
    }
}
