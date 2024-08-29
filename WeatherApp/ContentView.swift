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
        NavigationStack {
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
                
                if let previousLocationWeather = viewModel.previousLocationWeather {
                    Section {
                        LocationWeatherCard(weatherResult: previousLocationWeather)
                    } header: {
                        Text("Previous Location")
                    }
                }
                
                Section {
                    NavigationLink(destination: MyLocationView().navigationTitle("My Location")) {
                        Text("Get My Location")
                    }
                }
                
            }
            .navigationTitle("Weather Report")
        }
    }
}


struct LocationWeatherCard: View {
    var weatherResult: Result<WeatherInfo, String>?
    var body: some View {
        switch weatherResult {
        case .success(let info):
            VStack(alignment: .leading) {
                Text("Location: ") + Text(info.name)
                Text("Current Temp: ")  + Text(info.temparature.tempInCelsius)
                Text("Feels like: ") + Text(info.temparature.feelsLikeInCelsius)
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
                        Text(info.prominentCondition?.main ?? "")
                        Text(info.prominentCondition?.description ?? "")
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
