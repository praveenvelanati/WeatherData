//
//  LocationManager.swift
//  WeatherApp
//
//  Created by praveen velanati on 8/28/24.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    @Published var authStatus: CLAuthorizationStatus?
    
    var locationPermissionAvailable: Bool {
        return authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways
    }
    
    var permissionDenied: Bool {
        return authStatus == .denied || authStatus == .restricted
    }
    
    @Published var currentLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() {
        if locationPermissionAvailable {
            locationManager.requestLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus
        locationManager.requestLocation()
    }
}
