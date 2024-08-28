//
//  Weather.swift
//  WeatherApp
//
//  Created by praveen velanati on 8/28/24.
//

import Foundation

struct Coordinates: Codable {
    let lat: Double
    let lon: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
}

struct Clouds: Codable {
    let all: CGFloat
}
struct Rain: Codable {
    let oneHour: CGFloat
    
    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
    }
}

