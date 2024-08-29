//
//  WeatherService.swift
//  WeatherApp
//
//  Created by praveen velanati on 8/28/24.
//

import Foundation

protocol WeatherServiceType {
    func getWeather(httpEndpoint: HTTPEndpoint) async throws -> WeatherInfo
}

struct WeatherService: WeatherServiceType {
    let httpClient: HttpClient
    
    func getWeather(httpEndpoint: HTTPEndpoint) async throws -> WeatherInfo {
        if let request = httpEndpoint.urlRequest {
            let data = try await httpClient.makeRequest(request: request)
            return try httpClient.decode(data: data)
        } else {
            throw NetworkError.invalidRequest
        }
    }
}
