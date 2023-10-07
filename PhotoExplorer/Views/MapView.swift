//
//  MainView.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 07.10.2023.
//

import SwiftUI
import MapKit
import CoreLocation


import SwiftUI
import MapKit

import SwiftUI
import MapKit

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var viewModel: FlickrAuthViewModel
    @ObservedObject var mapViewModel = MapViewModel()
    @EnvironmentObject var locationManager: LocationManager // Access LocationManager

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        Map(
            coordinateRegion: $region,
            interactionModes: .all,
            showsUserLocation: true
        )
        .onAppear {
            // Wait for a brief moment before centering the map on the user's location
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                if let userLocation = locationManager.lastKnownLocation?.coordinate {
                    region.center = userLocation
                }
            }

            // Start location updates
            mapViewModel.startLocationUpdates()
        }
    }
}












struct Location: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
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
