//
//  MainView.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 07.10.2023.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @EnvironmentObject var viewModel: FlickrAuthViewModel
    @ObservedObject var mapViewModel = MapViewModel()
    @EnvironmentObject var locationManager: LocationService // Access LocationManager
    
    @State private var region: MKCoordinateRegion

    init() {
        // Default to San Francisco
        let defaultLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        _region = State(initialValue: MKCoordinateRegion(center: defaultLocation, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    }

    var body: some View {
        CustomMapView(initialRegion: $region, onMapTap: { coordinate in
            // Handle tap on map
            mapViewModel.handleTapOnMap(at: coordinate)
        })
        .onAppear {
            if let userLocation = locationManager.lastKnownLocation?.coordinate {
                region.center = userLocation
            }
        }
        .onReceive(locationManager.$lastKnownLocation) { newLocation in
            guard let newLocation = newLocation?.coordinate else { return }
            region.center = newLocation
        }
    }
}


struct CustomMapView: UIViewRepresentable {
    @Binding var initialRegion: MKCoordinateRegion
    var onMapTap: (CLLocationCoordinate2D) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.mapTapped(_:)))
        mapView.addGestureRecognizer(tap)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if !context.coordinator.didSetInitialRegion {
            DispatchQueue.main.async {
                uiView.setRegion(self.initialRegion, animated: true)
                context.coordinator.didSetInitialRegion = true
            }
        }
    }


    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        var didSetInitialRegion = false

        init(_ parent: CustomMapView) {
            self.parent = parent
        }

        @objc func mapTapped(_ gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            parent.onMapTap(coordinate)
        }
    }
}


