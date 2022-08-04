//
//  NetworkError.swift
//  NYCSchools
//
//  Created by Sudarshan Sharma on 8/3/22.
//

import Foundation

enum NetworkError: Error {
    case badRequest
    case other(Error)
    case unableToDecode
    case url(URLError?)
}
