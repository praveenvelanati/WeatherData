//
//  LocationViewModel.swift
//  WeatherAppTests
//
//  Created by praveen velanati on 8/29/24.
//

import XCTest
@testable import WeatherApp

final class LocationViewModelTests: XCTestCase {

    var sut: LocationViewModel!
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testQueryItems() async {
        let mockService = MockWeatherService(throwError: false)
        sut = LocationViewModel(service: mockService)
        let items = sut.queryItemsForLatLong(location: .init(latitude: 0.0, longitude: 0.0))
        XCTAssert(items.count == 2)
    }
    
    func testWeatherForLocation() async {
        let mockService = MockWeatherService(throwError: false)
        sut = LocationViewModel(service: mockService)
        await sut.weatherForLocation(location: .init(latitude: 0.0, longitude: 0.0))
        switch sut.currentLocationWeather {
        case .success(let info):
            XCTAssertNotNil(info.name)
        case .failure(_):
            XCTFail()
        case .none:
            XCTFail()
        }
    }

    func testWeatherForLocationWithError() async {
        let mockService = MockWeatherService(throwError: true)
        sut = LocationViewModel(service: mockService)
        await sut.weatherForLocation(location: .init(latitude: 0.0, longitude: 0.0))
        switch sut.currentLocationWeather {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssert(!error.isEmpty)
        case .none:
            XCTFail()
        }
    }
   
}
