//
//  FlickrPhotosResponse.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 02.10.2023.
//

import Foundation

struct FlickrPhotosResponse: Codable {
    let photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case photos = "photo"
    }
}
