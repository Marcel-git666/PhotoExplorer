//
//  NetworkManager.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 03.10.2023.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse
    case invalidData
    case invalidURL
}

class NetworkManager: ObservableObject {
    func getPhotos() async throws -> [Photo] {
        let endpoint = FlickrAPI.baseURLString + "/?method" + Endpoint.forLocationPhotos.rawValue + "api_key=" + FlickrAPI.apiKey
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Photo].self, from: data)
        } catch {
            throw NetworkError.invalidData
        }
    }
}

//URL: https://www.flickr.com/services/rest/?method=flickr.photos.geo.photosForLocation&api_key=020690bad5542543b541b48ac2d79dfa&format=rest&auth_token=72157720895850950-db39677b3394eccf&api_sig=f9ac27ac8c73972b91b9309e81227502
