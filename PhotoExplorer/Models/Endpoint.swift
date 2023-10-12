//
//  Endpoint.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 02.10.2023.
//

enum Endpoint: String {
    case search = "flickr.photos.search"
    case forLocationPhotos = "flickr.photos.geo.photosForLocation"
    case test = "flickr.test.login"
}


// URL: https://www.flickr.com/services/rest/?method=flickr.photos.geo.photosForLocation&api_key=f366b7e2540077cea2a13821ace6bfea&format=rest&auth_token=72157720895781960-5747744bc422756a&api_sig=2506e3eed4c1f60f1f37d23eb56b69ce
