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
    let isPublic: String
    let isFriend: String
    let isFamily: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case server
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
    
}
