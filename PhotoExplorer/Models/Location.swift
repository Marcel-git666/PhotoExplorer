//
//  Location.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 08.10.2023.
//

import MapKit

struct Location: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
}
