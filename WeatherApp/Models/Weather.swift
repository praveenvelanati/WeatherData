//
//  Weather.swift
//  WeatherApp
//
//  Created by praveen velanati on 8/28/24.
//

import Foundation

// Here all the properties could be optional as there is documentation on it, assuming that these are not for simplicity
struct Coordinates: Codable {
    let lat: Double
    let lon: Double
}

struct WeatherCondition: Codable {
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

struct WeatherInfo: Codable {
    let main: Main?
    let weather: [WeatherCondition]
    let name: String?
    
    var firstMatch: WeatherCondition? {
        weather.first
    }
    
    var iconURL: URL? {
        URL(string: "https://openweathermap.org/img/wn/\(firstMatch?.icon ?? "")@2x.png")
    }
    
}
