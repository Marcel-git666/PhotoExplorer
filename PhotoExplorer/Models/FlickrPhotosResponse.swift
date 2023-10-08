//
//  FlickrPhotosResponse.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 02.10.2023.
//

import Foundation

struct FlickrPhotosResponse: Codable {
    let photos: PhotosContainer
}

struct PhotosContainer: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [Photo]
}


