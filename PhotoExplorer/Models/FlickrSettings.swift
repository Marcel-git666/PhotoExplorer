//
//  FlickrSettings.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 08.10.2023.
//

import SwiftUI
import MapKit

class FlickrSettings: ObservableObject {
    @Published var selectedEndpoint: Endpoint = .forLocationPhotos
    @Published var accuracy: Double = 16.0
    
    func testAPI(using service: FlickrPhotoService) {
            Task {
                do {
                    let mockCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
                    let photos = try await service.getPhotos(for: mockCoordinate, endpoint: .test, accuracy: 1)
                    print(photos)
                } catch {
                    print("Error testing the API: \(error.localizedDescription)")
                }
            }
        }
}
