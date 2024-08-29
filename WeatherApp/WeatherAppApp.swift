//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by praveen velanati on 8/28/24.
//

import SwiftUI

@main
struct WeatherAppApp: App {
    
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: .init(service: WeatherService(httpClient: .init(session: .shared, decoder: getDecoder()))))
        }
    }
    
    func getDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
