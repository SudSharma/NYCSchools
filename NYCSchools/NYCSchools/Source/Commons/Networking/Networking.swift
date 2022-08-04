//
//  Networking.swift
//  NYCSchools
//
//  Created by Sudarshan Sharma on 8/3/22.
//

import Combine
import Foundation

class Networking {
    func dataTaskPublisher<T: Decodable>(for request: Request, type: T.Type) -> AnyPublisher<T, Error>? {
        guard let urlRequest = request.urlRequest else {
            return Fail(error: NetworkError.badRequest).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                switch error {
                case is DecodingError:
                    return NetworkError.unableToDecode
                    
                case is URLError:
                    return NetworkError.url(error as? URLError)
                    
                default:
                    return NetworkError.other(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
