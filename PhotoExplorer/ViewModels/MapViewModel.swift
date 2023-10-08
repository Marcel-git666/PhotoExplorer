//
//  MainViewModel.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 07.10.2023.
//


import Foundation
import CoreLocation
import MapKit

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var locations: [Location] = []
    @Published var selectedLocation: Location?
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var lastTappedCoordinate: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        startLocationUpdates()
    }
    
    func startLocationUpdates() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func handleTapOnMap(at coordinate: CLLocationCoordinate2D) {
        // Handle the tap on the map
        selectedLocation = Location(id: UUID(), coordinate: coordinate)
        lastTappedCoordinate = coordinate
        print("User has tapped on coordinates: \(lastTappedCoordinate.debugDescription).")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate {
            userLocation = location
        }
    }
}
