//
//  NetworkManager.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 03.10.2023.
//

import Foundation
import MapKit

enum NetworkError: Error {
    case invalidResponse
    case invalidData
    case invalidURL
}

class FlickrPhotoService: ObservableObject {
    func getPhotos(for coordinate: CLLocationCoordinate2D) async throws -> [Photo] {
            let endpoint = "\(FlickrAPI.baseURLString)/?method=\(Endpoint.search.rawValue)&api_key=\(FlickrAPI.apiKey)&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&format=json&nojsoncallback=1"
            
            guard let url = URL(string: endpoint) else {
                throw NetworkError.invalidURL
            }

            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }
            
            do {
                let decoder = JSONDecoder()
                let flickrResponse = try decoder.decode(FlickrPhotosResponse.self, from: data)
                return flickrResponse.photos.photo
            } catch {
                print("Decoding error:", error)
                throw NetworkError.invalidData
            }
        }
}



//URL: https://www.flickr.com/services/rest/?method=flickr.photos.geo.photosForLocation&api_key=020690bad5542543b541b48ac2d79dfa&format=rest&auth_token=72157720895850950-db39677b3394eccf&api_sig=f9ac27ac8c73972b91b9309e81227502
