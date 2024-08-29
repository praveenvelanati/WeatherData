//
//  HttpClient.swift
//  WeatherApp
//
//  Created by praveen velanati on 8/28/24.
//

import Foundation

// Ideally HttpClient should conform to a protocol in which session can be mocked.
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
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}

enum NetworkError: Error {
    case invalidRequest
    case invalidResponse
    case decodingError
}
