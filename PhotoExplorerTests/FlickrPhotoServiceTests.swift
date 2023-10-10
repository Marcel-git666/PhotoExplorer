//
//  FlickrPhotoServiceTests.swift
//  PhotoExplorerTests
//
//  Created by Marcel Mravec on 09.10.2023.
//

import XCTest
import MapKit

@testable import PhotoExplorer

class FlickrPhotoServiceTests: XCTestCase {
    var service: FlickrPhotoService!
    var mockSession: URLSessionMock!

    let someURL = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.geo.photosForLocation&api_key=b6807b0531c47c31475f6070e735c3b0&lat=43.092461&lon=-79.047150&accuracy=16&format=json&nojsoncallback=1&auth_token=72157720896399348-fe7716c312ad95eb&api_sig=b42b1ff54c0a1d2651f54d2d27b49854")!
    let someCoordinate = CLLocationCoordinate2D(latitude: 43.092461, longitude: -79.047150) // Adjust this as needed
    let expectedPhotoCount = 0 // Adjust this as needed based on the mock data

    override func setUp() {
        super.setUp()
        mockSession = URLSessionMock()
        service = FlickrPhotoService()
    }

    func testSuccessfulPhotoFetch() async {
        let mockData = """
{"photos":{"page":1,"pages":0,"perpage":100,"total":0,"photo":[]},"stat":"ok"}"
""".data(using: .utf8)!
        mockSession.mockData = mockData
        mockSession.mockURLResponse = HTTPURLResponse(url: someURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let photos = try? await service.getPhotos(for: someCoordinate, endpoint: .forLocationPhotos, accuracy: 5)
        
        XCTAssertNotNil(photos)
        XCTAssertEqual(photos?.count, expectedPhotoCount) // whatever number you expect
    }
    
    func testFailedPhotoFetch() async {
        mockSession.mockError = NSError(domain: "", code: 0, userInfo: nil)
        
        do {
            let _ = try await service.getPhotos(for: someCoordinate, endpoint: .search, accuracy: 5)
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertEqual(error as? NetworkError, .invalidResponse)
        }
    }

}

