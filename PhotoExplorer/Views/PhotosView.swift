//
//  PhotosView.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 08.10.2023.
//

import SwiftUI

struct PhotosView: View {
    @ObservedObject var mapViewModel: MapViewModel
    // Assume you have some method to fetch photos based on coordinates.
    @ObservedObject var photosViewModel = PhotosViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Photos at Tapped Coordinate")

            if let coordinate = mapViewModel.lastTappedCoordinate {
                Text("Latitude: \(coordinate.latitude)")
                Text("Longitude: \(coordinate.longitude)")

//                List(photosViewModel.photos, id: \.id) { photo in
//                    // Display each photo in a row.
//                    // You'll likely have a photo view model or similar to handle this.
//                    Image(uiImage: photo.image)
//                        .resizable()
//                        .scaledToFit()
//                }
            } else {
                Text("Tap on the map to get coordinates and see photos")
            }
        }
        .padding()
        .onReceive(mapViewModel.$lastTappedCoordinate) { newCoordinate in
            guard let newCoordinate = newCoordinate else { return }
            photosViewModel.fetchPhotos(at: newCoordinate)
        }
    }
}
