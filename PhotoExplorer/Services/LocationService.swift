//
//  LocationService.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 08.10.2023.
//

import MapKit

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var innerLocationManager = CLLocationManager()
    
    @Published var lastKnownLocation: CLLocation?
    
    override init() {
        super.init()
        self.innerLocationManager.delegate = self
        self.innerLocationManager.requestWhenInUseAuthorization()
        self.innerLocationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.last
    }
}
