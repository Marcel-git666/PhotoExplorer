//
//  PhotosViewModel.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 08.10.2023.
//

import SwiftUI
import MapKit
import Prephirences

class PhotosViewModel: ObservableObject {
    @EnvironmentObject var flickrSettings: FlickrSettings
    private var photoService = FlickrPhotoService()
    
    @Published var photos: [Photo] = []
    @Published var errorMessage: String?
    
    func fetchPhotos(for coordinate: CLLocationCoordinate2D, endpoint: Endpoint, accuracyValue: Double) {
        self.errorMessage = nil
        Task {
            do {
                let accuracy = Int(accuracyValue.rounded())
                let fetchedPhotos = try await photoService.getPhotos(for: coordinate, endpoint: endpoint, accuracy: accuracy)
                self.photos = fetchedPhotos
                
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "An error occurred: \(error.localizedDescription)"
                }
            }
        }
    }
}


