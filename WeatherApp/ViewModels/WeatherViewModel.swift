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

class WeatherViewModel: ObservableObject {
    var subscriptions = Set<AnyCancellable>()
    @Published var requestedLocationWeather: Result<WeatherInfo, String>?
    @Published var currentLocationWeather: Result<WeatherInfo, String>?
    @Published var previousLocationWeather: Result<WeatherInfo, String>?
    private var locationManager = LocationManager()
    let service: WeatherServiceType
    
    var shouldRequestPermission: Bool {
        return locationManager.shouldRequestPermission
    }
    
    var locationPermissionAvailable: Bool {
        return locationManager.locationPermissionAvailable
    }
    
    var permissionDenied: Bool {
        return locationManager.permissionDenied
    }
    init(service: WeatherServiceType) {
        self.service = service
        locationManager.$currentLocation
            .receive(on: DispatchQueue.main)
            .sink { location in
                guard let currentLocation = location else {
                    return
                }
                Task {
                   await self.weatherForLocation(location: currentLocation)
                }
            }
            .store(in: &subscriptions)
        if let previousLocation = UserDefaults.standard.value(forKey: "locationCache") as? String {
            Task {
                await weatherForStoredLocation(city: previousLocation)
            }
        }
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    @MainActor func weatherForSearch(city: String) async {
        do {
            requestedLocationWeather = .success(try await weatherForAcity(city: city))
        } catch {
            requestedLocationWeather = .failure(error.localizedDescription)
        }
    }
    
    @MainActor func weatherForStoredLocation(city: String) async {
        do {
            previousLocationWeather = .success(try await weatherForAcity(city: city))
        } catch {
            previousLocationWeather = .failure(error.localizedDescription)
        }
    }
    
    @MainActor func weatherForAcity(city: String) async throws -> WeatherInfo {
        guard !city.isEmpty else {
            throw "Validation Error"
        }
        let queryItem1 = URLQueryItem(name: "q", value: city)
        let queryItem2 = URLQueryItem(name: "appid", value: "3431298cbcb1efb08600238c3490fb89")
        let httpEndpoint = HTTPEndpoint(scheme: "https", domain: "api.openweathermap.org", path: "/data/2.5/weather", headers: nil, queryItems: [queryItem1, queryItem2], httpMethod: "GET")
        return try await service.getWeather(httpEndpoint: httpEndpoint)
    }
    
    @MainActor func weatherForLocation(location: CLLocationCoordinate2D) async {
        let queryItem1 = URLQueryItem(name: "lat", value: "\(location.latitude)")
        let queryItem2 = URLQueryItem(name: "lon", value: "\(location.longitude)")
         let queryItem3 = URLQueryItem(name: "appid", value: "3431298cbcb1efb08600238c3490fb89")
         let httpEndpoint = HTTPEndpoint(scheme: "https", domain: "api.openweathermap.org", path: "/data/2.5/weather", headers: nil, queryItems: [queryItem1, queryItem2, queryItem3], httpMethod: "GET")
         do {
             currentLocationWeather = .success(try await service.getWeather(httpEndpoint: httpEndpoint))
         } catch {
             currentLocationWeather = .failure(error.localizedDescription)
         }
     }
    
}

