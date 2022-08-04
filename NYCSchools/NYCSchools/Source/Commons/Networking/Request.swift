//
//  Request.swift
//  NYCSchools
//
//  Created by Sudarshan Sharma on 8/3/22.
//

import Foundation

protocol RequestProtocol {
    
}

struct Request: RequestProtocol {
    var queryParameters: [URLQueryItem]?
    var urlRequest: URLRequest? {
        var urlComponent = URLComponents(string: url)
        if let queryParameters = queryParameters {
            urlComponent?.queryItems = queryParameters
        }
        
        guard let url = urlComponent?.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(Constants.appToken, forHTTPHeaderField: "X-App-Token")
        
        return urlRequest
    }
    let url: String
    
    init(_ url: String, queryParameters: [URLQueryItem]? = nil) {
        self.url = url
        self.queryParameters = queryParameters
    }
}
