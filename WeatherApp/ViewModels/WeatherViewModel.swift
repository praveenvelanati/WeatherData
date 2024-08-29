//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by praveen velanati on 8/28/24.
//

import Foundation
import Combine
import CoreLocation

extension String: Error { }

final class WeatherViewModel: ObservableObject {
    // Stores subscription for location updates
    var subscriptions = Set<AnyCancellable>()
    // Data for Requested location. Contains both Model and error
    @Published var requestedLocationWeather: Result<WeatherInfo, String>?
    // Data for Previous location. Contains both Model and error
    @Published var previousLocationWeather: Result<WeatherInfo, String>?
    
    let service: WeatherServiceType
    let baseEndpoint = HTTPEndpoint(scheme: "https", domain: "api.openweathermap.org", path: "/data/2.5/weather", headers: nil, queryItems: [URLQueryItem(name: "appid", value: "3431298cbcb1efb08600238c3490fb89")], httpMethod: "GET")
    
    init(service: WeatherServiceType) {
        self.service = service
        getWeatherForPreviousLocation()
    }
    
    
    // Here we can have take the user defaults and key as parameters and unit the function using inMemory user defaults suit.
    private func getWeatherForPreviousLocation() {
        if let previousLocation = UserDefaults.standard.value(forKey: "locationCache") as? String {
            Task {
                await weatherForStoredLocation(city: previousLocation)
            }
        }
    }
    
    // Gets Weather Info for Search item
    @MainActor func weatherForSearch(city: String) async {
        do {
            requestedLocationWeather = .success(try await weatherForAcity(city: city))
        } catch {
            requestedLocationWeather = .failure(error.localizedDescription)
        }
    }
    
    // Gets Weather Info for stored item
    @MainActor func weatherForStoredLocation(city: String) async {
        do {
            previousLocationWeather = .success(try await weatherForAcity(city: city))
        } catch {
            previousLocationWeather = .failure(error.localizedDescription)
        }
    }
    
    // Gets Weather Info for a city.
    @MainActor func weatherForAcity(city: String) async throws -> WeatherInfo {
        guard !city.isEmpty else {
            throw "Validation Error"
        }
        let queryItem = URLQueryItem(name: "q", value: city)
        var httpEndpoint = baseEndpoint
        httpEndpoint.queryItems?.append(queryItem)
        return try await service.getWeather(httpEndpoint: httpEndpoint)
    }
    
}

