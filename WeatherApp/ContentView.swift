//
//  ContentView.swift
//  WeatherApp
//
//  Created by praveen velanati on 8/28/24.
//

import SwiftUI

struct ContentView: View {
    @State private var location: String = ""
    @AppStorage("locationCache") private var previousLocation: String = ""
    @StateObject var viewModel: WeatherViewModel
    var body: some View {
        List {
            Section {
                VStack {
                    TextField("Enter Location", text: $location)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        previousLocation = location
                        Task {
                            await viewModel.weatherForSearch(city: location)
                        }
                    } label: {
                        Text("Get Weather Info")
                    }.buttonStyle(.borderedProminent)
                    if let info = viewModel.requestedLocationWeather {
                        LocationWeatherCard(weatherResult: info)
                    }
                }
            }
            
            Section {
                VStack {
                    if viewModel.permissionDenied {
                        Text("Location permission denied. Please go to settings to give location permissions")
                    } else if viewModel.shouldRequestPermission {
                        Button {
                            viewModel.requestLocation()
                        } label: {
                            Text("Grant Location Permission")
                        }.buttonStyle(.borderedProminent)
                    } else {
                        if let currentLocationWeather = viewModel.currentLocationWeather {
                            LocationWeatherCard(weatherResult: currentLocationWeather)
                        } else {
                            ProgressView {
                                Text("Fetching weather info for current location")
                            }
                        }
                    }
                }
            } header: {
                Text("Current Location")
            }
            
            if let previousLocationWeather = viewModel.previousLocationWeather {
                Section {
                    LocationWeatherCard(weatherResult: previousLocationWeather)
                } header: {
                    Text("Previous Location")
                }
            }
            
        }
    }
}


struct LocationWeatherCard: View {
    var weatherResult: Result<WeatherInfo, String>?
    var body: some View {
        switch weatherResult {
        case .success(let info):
            VStack(alignment: .leading) {
                Text("Location: ") + Text(info.name ?? "")
                Text("Current Temp: \(info.main?.temp ?? 0.0)")
                Text("Feels like: \(info.main?.feelsLike ?? 0.0)")
                HStack {
                    AsyncImage(url: info.iconURL) { phase in
                        switch phase {
                        case .empty:
                            Color.clear
                                .frame(width: 50, height: 50)
                        case .success(let image):
                            image.resizable().frame(width: 50, height: 50)
                        case .failure(_):
                            Color.clear
                                .frame(width: 50, height: 50)
                        @unknown default:
                            fatalError()
                        }
                    }
                    VStack(alignment: .leading) {
                        Text(info.weather.first?.main ?? "")
                        Text(info.weather.first?.description ?? "")
                    }
                }
            }
        case .failure(let failure):
            Text(failure)
        case .none:
            Text("Unknown error")
        }
    }
}
