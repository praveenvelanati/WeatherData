//
//  HttpClient.swift
//  WeatherApp
//
//  Created by praveen velanati on 8/28/24.
//

import Foundation





struct HttpClient {
    
    let session: URLSession
    let decoder: JSONDecoder
    
    func makeRequest(request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        return data
    }
    
    func decode<T: Decodable>(data: Data) throws -> T {
         return try decoder.decode(T.self, from: data)
    }
}

enum NetworkError: Error {
    case invalidRequest
    case invalidResponse
}
