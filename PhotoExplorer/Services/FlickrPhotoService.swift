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
        let actualRequest: URLRequest
        
        switch endpoint {
        case .search:
            if let url = URL(string: "\(FlickrAPI.baseURLString)/?method=\(Endpoint.search.rawValue)&api_key=\(FlickrAPI.apiKey)&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&format=json&nojsoncallback=1") {
                actualRequest = URLRequest(url: url)
            } else {
                throw NetworkError.invalidURL
            }
            
        case .forLocationPhotos:
            do {
                let constructedURL = try constructURL(coordinate: coordinate, accuracy: accuracy)
                
                var request = URLRequest(url: URL(string: constructedURL)!, timeoutInterval: Double.infinity)
                // Set the custom Cookie header from the Postman request
                request.addValue("ccc=%7B%22needsConsent%22%3Afalse%2C%22managed%22%3A0%2C%22changed%22%3A0%2C%22info%22%3A%7B%22cookieBlock%22%3A%7B%22level%22%3A0%2C%22blockRan%22%3A0%7D%7D%7D", forHTTPHeaderField: "Cookie")
                
                request.httpMethod = "GET"
                actualRequest = request
            } catch {
                throw NetworkError.invalidURL
            }
            
        case .test:
            var testURL = "\(FlickrAPI.baseURLString)/"
            // Getting OAuth credentials
            let keychain = KeychainPreferences.sharedInstance
            guard let accessToken = keychain.string(forKey: "flickrAccessToken"),
                  let accessTokenSecret = keychain.string(forKey: "flickrAccessTokenSecret") else {
                throw NetworkError.authError
            }
            print("Loaded credentials from keychain token and secret: \(accessToken) and \(accessTokenSecret)")
            var parameters: [String: String] = [
                "nojsoncallback": "1",
                "format": "json",
                "oauth_consumer_key": FlickrAPI.apiKey,
                "oauth_timestamp": "\(Int(Date().timeIntervalSince1970))", // Using current timestamp
                "oauth_signature_method": "HMAC-SHA1",
                "oauth_version": "1.0",
                "method": "flickr.test.login"
            ]
            
            for (key, value) in parameters {
                testURL += "\(key)=\(value)&"
            }
            let oauthService = FlickrOAuthService()
            let signature = oauthService.oauthSignature(
                httpMethod: "GET",
                url: testURL,
                params: parameters,
                consumerSecret: FlickrAPI.secretKey,
                oauthTokenSecret: accessTokenSecret
            )
            print("Parameters for signature are: \(parameters) and secret: \(accessTokenSecret)")
            
            // Adding the signature to the parameters
            parameters["oauth_signature"] = signature
            testURL += "auth_token=\(accessToken)&api_sig=\(signature)"
            if let url = URL(string: testURL) {
                actualRequest = URLRequest(url: url)
            } else {
                throw NetworkError.invalidURL
            }
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
    
    func constructURL(coordinate: CLLocationCoordinate2D, accuracy: Int) throws -> String {
        var constructedURL = "\(FlickrAPI.baseURLString)/?method=\(Endpoint.forLocationPhotos.rawValue)&api_key=\(FlickrAPI.apiKey)&format=json&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&accuracy=\(accuracy)&oauth_consumer_key=\(FlickrAPI.apiKey)"
        
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
        print("Parameters for signature are: \(oauthParameters) and secret: \(accessTokenSecret)")
        
        // Adding the signature to the parameters
        oauthParameters["oauth_signature"] = signature
        
        constructedURL += "&auth_token=\(accessToken)&api_sig=\(signature)"
        print("ConstructedURL for API call is: \(constructedURL)")
        return constructedURL
    }
}

//https://www.flickr.com/services/rest/?method=flickr.photos.geo.photosForLocation&api_key=b6807b0531c47c31475f6070e735c3b0&lat=43.092461&lon=-79.047150&accuracy=16&format=json&nojsoncallback=1&auth_token=72157720896399348-fe7716c312ad95eb&api_sig=b42b1ff54c0a1d2651f54d2d27b49854

//constructedURL = "\(FlickrAPI.baseURLString)/?method=\(Endpoint.forLocationPhotos.rawValue)&api_key=\(FlickrAPI.apiKey)&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&accuracy=\(accuracy)&format=json&nojsoncallback=1&auth_token=\(accessToken)&api_sig=\(signature)"
//
//var request = URLRequest(url: URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.geo.photosForLocation&api_key=423fd69a15c73a10ef027e5941cf08e7&format=json&lat=43.092461&lon=-79.047150&accuracy=1&oauth_consumer_key=423fd69a15c73a10ef027e5941cf08e7&oauth_token=72157720896461187-75ddda60e280430f&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1697055867&oauth_nonce=oEyr7FacioQ&oauth_version=1.0&oauth_signature=a1fs0GX%2BqjAD6GcOw0h3ST4NCQs%3D")!,timeoutInterval: Double.infinity)
//request.addValue("ccc=%7B%22needsConsent%22%3Afalse%2C%22managed%22%3A0%2C%22changed%22%3A0%2C%22info%22%3A%7B%22cookieBlock%22%3A%7B%22level%22%3A0%2C%22blockRan%22%3A0%7D%7D%7D", forHTTPHeaderField: "Cookie")
//
//request.httpMethod = "GET"
//
//let task = URLSession.shared.dataTask(with: request) { data, response, error in
//  guard let data = data else {
//    print(String(describing: error))
//    return
//  }
//  print(String(data: data, encoding: .utf8)!)
//}
//
//task.resume()
