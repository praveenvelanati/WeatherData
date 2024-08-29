//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by praveen velanati on 8/28/24.
//

import XCTest
@testable import WeatherApp

final class WeatherAppTests: XCTestCase {

    var sut: WeatherViewModel!
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testWeatherForSearchWithError() async {
        let mockService = MockWeatherService(throwError: true)
        sut = WeatherViewModel(service: mockService)
        await sut.weatherForSearch(city: "")
        switch sut.requestedLocationWeather {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssert(!error.isEmpty)
        case .none:
            XCTFail()
        }
    }
    
    func testWeatherForSearchWithData() async {
        let mockService = MockWeatherService(throwError: false)
        sut = WeatherViewModel(service: mockService)
        await sut.weatherForSearch(city: "Plano")
        switch sut.requestedLocationWeather {
        case .success(let info):
            XCTAssertNotNil(info.name)
        case .failure(_):
            XCTFail()
        case .none:
            XCTFail()
        }
    }
    
    func testWeatherForACityWithEmpty() async {
        let mockService = MockWeatherService(throwError: false)
        sut = WeatherViewModel(service: mockService)
        do {
            _ = try await sut.weatherForAcity(city: "")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
    }
}

struct MockWeatherService: WeatherServiceType {
    
    var throwError: Bool
    func getWeather(httpEndpoint: WeatherApp.HTTPEndpoint) async throws -> WeatherApp.WeatherInfo {
        if throwError {
            throw "Invalid Response"
        } else {
            return WeatherInfo(temparature: .init(temp: 10.00, feelsLike: 15.00, tempMin: 15.00, tempMax: 15.00), weatherConditions: [], name: "Plano")
        }
    }
}
