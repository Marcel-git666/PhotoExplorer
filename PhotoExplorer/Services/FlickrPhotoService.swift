//
//  NetworkManager.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 03.10.2023.
//

import Foundation
import MapKit
import Prephirences

enum NetworkError: Error {
    case invalidResponse
    case invalidData
    case invalidURL
    case authError
}

class FlickrPhotoService: ObservableObject {
    
    func getPhotos(for coordinate: CLLocationCoordinate2D, endpoint: Endpoint, accuracy: Int) async throws -> [Photo] {
        let constructedURL: String
        var request: URLRequest?
        
        switch endpoint {
        case .search:
            constructedURL = "\(FlickrAPI.baseURLString)/?method=\(Endpoint.search.rawValue)&api_key=\(FlickrAPI.apiKey)&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&format=json&nojsoncallback=1"
        case .forLocationPhotos:
            constructedURL = "\(FlickrAPI.baseURLString)/?method=\(Endpoint.forLocationPhotos.rawValue)&api_key=\(FlickrAPI.apiKey)&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&accuracy=\(accuracy)&format=json&nojsoncallback=1"
            
            // Getting OAuth credentials
            let keychain = KeychainPreferences.sharedInstance
            guard let accessToken = keychain.string(forKey: "flickrAccessToken"),
                  let accessTokenSecret = keychain.string(forKey: "flickrAccessTokenSecret") else {
                throw NetworkError.authError
            }
            print("Loadied credentials from keychain token and secret: \(accessToken) and \(accessTokenSecret)")
            // Generating the OAuth Signature
            let oauthService = FlickrOAuthService()
            let signature = oauthService.oauthSignature(
                httpMethod: "GET",
                url: constructedURL,
                params: ["oauth_token": accessToken],
                consumerSecret: FlickrAPI.secretKey,
                oauthTokenSecret: accessTokenSecret
            )
            
            // Creating the request with OAuth headers
            request = URLRequest(url: URL(string: constructedURL)!)
            
            let authHeader = "OAuth oauth_consumer_key=\"\(FlickrAPI.apiKey)\", oauth_token=\"\(accessToken)\", oauth_signature=\"\(signature)\""
            request?.addValue(authHeader, forHTTPHeaderField: "Authorization")

        }
        
        // Use the request object if it's set, otherwise use the constructed URL
        let actualRequest: URLRequest
        if endpoint == .forLocationPhotos, let oauthRequest = request {
            actualRequest = oauthRequest
        } else if let url = URL(string: constructedURL) {
            actualRequest = URLRequest(url: url)
        } else {
            throw NetworkError.invalidURL
        }
        print("Actual request is: \n \(actualRequest)")
        // Now make the request:
        let (data, response) = try await URLSession.shared.data(for: actualRequest)

        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("Response error is \(response)")
            throw NetworkError.invalidResponse
        }
        print(String(data: data, encoding: .utf8) ?? "Invalid data")
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
