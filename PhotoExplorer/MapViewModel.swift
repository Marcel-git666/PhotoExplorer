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
        fetchPhotosFromFlickr(at: coordinate)
    }
    
    func fetchPhotosFromFlickr(at location: CLLocationCoordinate2D) {
        // Implement the logic to fetch photos from Flickr using the chosen location
        print("Fetching photos for location: \(location.latitude), \(location.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate {
            userLocation = location
        }
    }
}
