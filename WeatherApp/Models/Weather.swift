//
//  Weather.swift
//  WeatherApp
//
//  Created by praveen velanati on 8/28/24.
//

import Foundation

/*
 All the models can be unot tested by decoding data from a json file
 */

// Here all the properties could be optional as there is documentation on it, assuming that these are not for simplicity
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
    
    // Can be Unit tested
    var tempInCelsius: String {
        let inC = String(format: "%.2f", temp - 273.15)
        return "\(inC) ℃"
    }
    
    // Can be Unit tested
    var feelsLikeInCelsius: String {
        let inC = String(format: "%.2f", feelsLike - 273.15)
        return "\(inC) ℃"
    }
}

struct WeatherInfo: Codable {
    let temparature: Main
    let weatherConditions: [WeatherCondition]
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case temparature = "main"
        case weatherConditions = "weather"
        case name
    }
    
    //This could be tested by creating a Mock Weather Info and doing assertion that weather array isn't empty
    var prominentCondition: WeatherCondition? {
        weatherConditions.first
    }
    
    //This could be tested by creating a Mock Weather Info and doing assertion on the property
    var iconURL: URL? {
        URL(string: "https://openweathermap.org/img/wn/\(prominentCondition?.icon ?? "")@2x.png")
    }
    
}
