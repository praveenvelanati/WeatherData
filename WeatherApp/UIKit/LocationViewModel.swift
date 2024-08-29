//
//  LocationViewModel.swift
//  WeatherApp
//
//  Created by praveen velanati on 8/29/24.
//

import Foundation
import CoreLocation
import Combine

class LocationViewModel: ObservableObject {
    // Stores subscription for location updates
    var subscriptions = Set<AnyCancellable>()
   
    // Data for Current location. Contains both Model and error
    @Published var currentLocationWeather: Result<WeatherInfo, String>?
   
    @Published var locationPermissionMessage: String = "Grant Location Permission"
    
    // Ideally this locationManager can be of a protocol type with all the necessary variables and functions, so that those can be tested as WeatherServiceType
    private var locationManager = LocationManager()
    let service: WeatherServiceType
    let baseEndpoint = HTTPEndpoint(scheme: "https", domain: "api.openweathermap.org", path: "/data/2.5/weather", headers: nil, queryItems: [URLQueryItem(name: "appid", value: "3431298cbcb1efb08600238c3490fb89")], httpMethod: "GET")
        
    init(service: WeatherServiceType) {
        self.service = service
        subscribeToLocationUpdates()
    }
    
    // Here we can mock Location manager and update the value of current Location, to make sure we are getting the updated location. Ideally we can assign the updated location to a varaible on ViewModel
    func subscribeToLocationUpdates() {
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
        locationManager.$authStatus
            .receive(on: DispatchQueue.main)
            .sink { locationPermission in
                if locationPermission == .denied || locationPermission == .restricted {
                    self.locationPermissionMessage = "Location Permission Denied. Please go to settings to enable location permissions"
                } else {
                    self.locationPermissionMessage = "Fetching User location..."
                }
            }
            .store(in: &subscriptions)
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    // Gets Weather Info for a location.
    @MainActor func weatherForLocation(location: CLLocationCoordinate2D) async {
        let queryItems = queryItemsForLatLong(location: location)
        var httpEndpoint = baseEndpoint
        httpEndpoint.queryItems?.append(contentsOf: queryItems)
        do {
            currentLocationWeather = .success(try await service.getWeather(httpEndpoint: httpEndpoint))
        } catch {
            if let networkError = error as? NetworkError {
                currentLocationWeather = .failure(networkError.descriptiveMessage)
            } else {
                currentLocationWeather = .failure(error.localizedDescription)
            }
        }
    }
    
    // Returns query items for a location. Can be unit tested by passing in mock location and asserting the count and expected items
    func queryItemsForLatLong(location: CLLocationCoordinate2D) -> [URLQueryItem] {
        [ URLQueryItem(name: "lat", value: "\(location.latitude)"),
          URLQueryItem(name: "lon", value: "\(location.longitude)")]
    }
}
