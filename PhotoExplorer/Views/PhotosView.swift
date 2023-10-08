//
//  PhotosView.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 08.10.2023.
//

import SwiftUI
import MapKit

struct PhotosView: View {
    @EnvironmentObject var mapViewModel: MapViewModel
    @ObservedObject var photosViewModel = PhotosViewModel()
    @EnvironmentObject var flickrSettings: FlickrSettings

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Tapped Coordinate")
                if let coordinate = mapViewModel.lastTappedCoordinate {
                    Text("Latitude: \(coordinate.latitude, specifier: "%.4f")")
                    Text("Longitude: \(coordinate.longitude, specifier: "%.4f")")
                    Text(photosViewModel.errorMessage ?? "No error")
                    
                    // Display Photos
                    TabView {
                        ForEach(photosViewModel.photos, id: \.id) { photo in
                            if let imageUrl = photo.imageURL() {
                                AsyncImage(url: imageUrl) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 400) // Adjust this as needed
                } else {
                    Text("Tap on the map to get coordinates")
                }
            }
        }
        .padding()
        .onReceive(mapViewModel.$lastTappedCoordinate) { newCoordinate in
            if let newCoordinate = newCoordinate {
                photosViewModel.fetchPhotos(for: newCoordinate, endpoint: flickrSettings.selectedEndpoint, accuracyValue: flickrSettings.accuracy)
            }
        }
    }
}
