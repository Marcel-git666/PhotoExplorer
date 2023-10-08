//
//  PhotosViewModel.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 08.10.2023.
//

import Foundation
import MapKit
import Prephirences

class PhotosViewModel: ObservableObject {
    private var photoService = FlickrPhotoService()

    @Published var photos: [Photo] = []
    @Published var errorMessage: String?

    func fetchPhotos(for coordinate: CLLocationCoordinate2D) {
        Task {
            do {
                let fetchedPhotos = try await photoService.getPhotos(for: coordinate)
                
                // Dispatch UI updates to the main thread
                DispatchQueue.main.async {
                    self.photos = fetchedPhotos
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "An error occurred."
                }
            }
        }
    }
}


