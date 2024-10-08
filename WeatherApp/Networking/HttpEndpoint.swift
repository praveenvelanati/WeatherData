//
//  HttpEndpoint.swift
//  WeatherApp
//
//  Created by praveen velanati on 8/28/24.
//

import Foundation

struct HTTPEndpoint {
    let scheme: String
    let domain: String
    let path: String
    let headers: [String: String]?
    var queryItems: [URLQueryItem]?
    let httpMethod: String
    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = domain
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        guard urlComponents.url != nil else {
            return nil
        }
        return urlComponents.url
    }
    
    var urlRequest: URLRequest? {
        guard let url = url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.allHTTPHeaderFields = headers
        return request
    }
}
