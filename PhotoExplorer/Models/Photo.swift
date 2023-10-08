//
//  Photo.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 02.10.2023.
//

import Foundation

struct Photo: Codable, Identifiable {
    let id: String
    let owner: String
    let server: String
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case server
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
    enum SizeSuffix: String {
            case thumbnailSquare75 = "s"
            case thumbnailSquare150 = "q"
            case thumbnail100 = "t"
            case small240 = "m"
            case small320 = "n"
            case small400 = "w"
            case medium500 = ""
            case medium640 = "z"
            case medium800 = "c"
            case large1024 = "b"
            case large1600 = "h"
            case large2048 = "k"
            case original = "o"
            // ... add other sizes as needed
        }

        func imageURL(for size: SizeSuffix) -> URL? {
            let urlString: String
            switch size {
            case .original:
                // You'd need the original secret and format for this, which aren't provided in your current model
                urlString = "https://live.staticflickr.com/\(server)/\(id)_\(FlickrAPI.secretKey)_o.jpg"
            default:
                urlString = "https://live.staticflickr.com/\(server)/\(id)_\(FlickrAPI.secretKey)_\(size.rawValue).jpg"
            }
            return URL(string: urlString)
        }
}
