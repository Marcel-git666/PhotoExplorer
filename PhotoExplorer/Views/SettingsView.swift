//
//  SettingsView.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 07.10.2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: FlickrAuthViewModel

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
        }
        .padding()
    }
}
