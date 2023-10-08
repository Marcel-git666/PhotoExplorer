//
//  FlickrSettings.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 08.10.2023.
//

import Foundation

class FlickrSettings: ObservableObject {
    @Published var selectedEndpoint: Endpoint = .forLocationPhotos
    @Published var accuracy: Double = 16.0
}
