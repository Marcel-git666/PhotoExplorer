//
//  SettingsView.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 07.10.2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: FlickrAuthViewModel
    @EnvironmentObject var flickrSettings: FlickrSettings
    @EnvironmentObject var flickrService: FlickrPhotoService
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Authentication State: \(viewModel.isAuthenticated ? "Authenticated" : "Not Authenticated")")
            
            if viewModel.isAuthenticated {
                Button("Logout") {
                    viewModel.logout()
                }
            } else {
                Button("Authenticate") {
                    viewModel.authenticate()
                }
            }
            
            Divider()
            
            Picker("Endpoint", selection: $flickrSettings.selectedEndpoint) {
                Text("Search").tag(Endpoint.search)
                Text("For Location Photos").tag(Endpoint.forLocationPhotos)
            }.pickerStyle(SegmentedPickerStyle())
            
            if flickrSettings.selectedEndpoint == .forLocationPhotos {
                Text("Accuracy: \(descriptionForAccuracy(Int(flickrSettings.accuracy.rounded())))")
                Slider(value: $flickrSettings.accuracy, in: 1...16)
                    .padding([.leading, .trailing])
            }
            Divider()
            
            Button("Test API") {
                flickrSettings.testAPI(using: flickrService)
            }
        }
        .padding()
    }
    
    func descriptionForAccuracy(_ value: Int) -> String {
        switch value {
        case 1:
            return "World"
        case 2...3:
            return "Country"
        case 4...6:
            return "Region"
        case 7...11:
            return "City"
        case 12...16:
            return "Street"
        default:
            return "Unknown"
        }
    }
}


