//
//  LocationViewController.swift
//  WeatherApp
//
//  Created by praveen velanati on 8/29/24.
//

import UIKit
import SwiftUI
import Combine

class LocationViewController: UIViewController {
    
    var subs = Set<AnyCancellable>()
    @IBOutlet var locationButton: UIButton!
    @IBOutlet var infoStackView: UIStackView!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var feelsLikeLabel: UILabel!
    var viewModel: LocationViewModel
   
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.viewModel = LocationViewModel(service: WeatherService(httpClient: .init(session: .shared, decoder: decoder)))
        super.init(nibName: nibNameOrNil, bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.requestLocation()
        setupSubscriptions()
    }
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        viewModel.requestLocation()
    }
    
    
    func setupSubscriptions() {
        viewModel.$locationPermissionMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.locationButton.setTitle(title, for: .normal)
            }.store(in: &subs)
        viewModel.$currentLocationWeather
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success(let weatherInfo):
                    self?.setWeatherInfo(weatherInfo: weatherInfo)
                case .failure(let error):
                    self?.setErrorMessage(error: error)
                case .none:
                    print("Unknown error")
                }
            }.store(in: &subs)
    }
    
    /* Ideally hiding of views should be decided by viewmodel. This can be done by using a publisher binding for each UI segment
     We can have  different published properties to show/hide different controls. With this way everything is controlled by ViewModel
     */
    func setWeatherInfo(weatherInfo: WeatherInfo) {
        nameLabel.text = "Current Location: \(weatherInfo.name)"
        tempLabel.text = "Current Temp: \(weatherInfo.temparature.tempInCelsius)"
        feelsLikeLabel.text = "Feels Like: \(weatherInfo.temparature.feelsLikeInCelsius)"
        infoStackView.isHidden = false
        errorLabel.isHidden = true
        locationButton.isHidden = true
    }
    
    
    func setErrorMessage(error: String) {
        errorLabel.text = error
        infoStackView.isHidden = true
        locationButton.isHidden = true
    }
}

struct MyLocationView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> LocationViewController {
        return LocationViewController(nibName: "LocationViewController", bundle: .main)
    }
    
    func updateUIViewController(_ uiViewController: LocationViewController, context: Context) {
        
    }
    
}
