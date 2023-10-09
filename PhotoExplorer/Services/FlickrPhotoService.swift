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
        var myURL: String = ""
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
                print("Loaded credentials from keychain token and secret: \(accessToken) and \(accessTokenSecret)")
                
                // Standard OAuth 1.0 Parameters
                let nonce = UUID().uuidString
                let timestamp = "\(Int(Date().timeIntervalSince1970))"
                
                var oauthParameters: [String: String] = [
                    "oauth_consumer_key": FlickrAPI.apiKey,
                    "oauth_token": accessToken,
                    "oauth_version": "1.0",
                    "oauth_signature_method": "HMAC-SHA1",
                    "oauth_nonce": nonce,
                    "oauth_timestamp": timestamp
                ]
                
                // Generating the OAuth Signature (include oauthParameters in the signature generation)
                let oauthService = FlickrOAuthService()
                let signature = oauthService.oauthSignature(
                    httpMethod: "GET",
                    url: constructedURL,
                    params: oauthParameters,
                    consumerSecret: FlickrAPI.secretKey,
                    oauthTokenSecret: accessTokenSecret
                )
                
                // Adding the signature to the parameters
                oauthParameters["oauth_signature"] = signature
                
                // Creating the request with OAuth headers
//                request = URLRequest(url: URL(string: constructedURL)!)
//                
//                let authHeader = authorizationHeader(params: oauthParameters)
//                print("Header is: \(authHeader)")
//                request?.addValue(authHeader, forHTTPHeaderField: "Authorization")
            myURL = "\(FlickrAPI.baseURLString)/?method=\(Endpoint.forLocationPhotos.rawValue)&api_key=\(FlickrAPI.apiKey)&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&accuracy=\(accuracy)&format=json&nojsoncallback=1&auth_token=\(accessToken)&api_sig=\(signature)"


        }
        
        // Use the request object if it's set, otherwise use the constructed URL
        let actualRequest: URLRequest
        if endpoint == .forLocationPhotos, let url = URL(string: myURL) {
                actualRequest = URLRequest(url: url)
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

//https://www.flickr.com/services/rest/?method=flickr.photos.geo.photosForLocation&api_key=b6807b0531c47c31475f6070e735c3b0&lat=43.092461&lon=-79.047150&accuracy=16&format=json&nojsoncallback=1&auth_token=72157720896399348-fe7716c312ad95eb&api_sig=b42b1ff54c0a1d2651f54d2d27b49854

//constructedURL = "\(FlickrAPI.baseURLString)/?method=\(Endpoint.forLocationPhotos.rawValue)&api_key=\(FlickrAPI.apiKey)&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&accuracy=\(accuracy)&format=json&nojsoncallback=1&auth_token=\(accessToken)&api_sig=\(signature)"

