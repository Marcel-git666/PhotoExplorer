//
//  PhotosViewModel.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 08.10.2023.
//

import Foundation
import MapKit

class PhotosViewModel: ObservableObject {
    @Published var photos: [Photo] = []

    func fetchPhotos(at coordinate: CLLocationCoordinate2D) {
        // Logic to fetch photos based on the coordinate.
        // Update the photos array with fetched photos.
    }
}

