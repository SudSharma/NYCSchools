//
//  SchoolsListDataSource.swift
//  NYCSchools
//
//  Created by Sudarshan Sharma on 8/3/22.
//

import Combine

protocol SchoolsListDataSourceProtocol {
    func fetchSchools() -> AnyPublisher<[School], Error>?
}

class SchoolsListDataSource: SchoolsListDataSourceProtocol {
    func fetchSchools() -> AnyPublisher<[School], Error>? {
        let request = Request(Constants.schoolsListURL)
        
        return Networking().dataTaskPublisher(for: request, type: [School].self)?
            .eraseToAnyPublisher()
    }
}
