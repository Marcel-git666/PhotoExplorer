//
//  FlickrAuthViewModel.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 03.10.2023.
//

import SwiftUI
import Combine

class FlickrAuthViewModel: ObservableObject {
    @Published var oauthService = FlickrOAuthService()
    @Published var isAuthenticated: Bool = false
    @Published var showSheet: Bool = false
    private var cancellables: Set<AnyCancellable> = []
    @Published var photos: [Photo] = []

    init() {
        // Initialize your OAuth service and check if the user is already authenticated
        checkAuthentication()
        oauthService.$showSheet
                    .sink(receiveValue: { [weak self] show in
                        self?.showSheet = show
                    })
                    .store(in: &cancellables)
        oauthService.$authenticationState
                            .sink(receiveValue: { [weak self] state in
                                self?.isAuthenticated = (state == .successfullyAuthenticated)
                            })
                            .store(in: &cancellables)
    }

    func checkAuthentication() {
        // Check if the user is already authenticated
        if oauthService.authenticationState == .successfullyAuthenticated {
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }
    }

    func authenticate() {
        // Start the authentication process
        oauthService.authorize()

        // Handle the UI state based on authenticationState
        if oauthService.authenticationState != .successfullyAuthenticated {
            // Show the SafariView if authentication is needed
            oauthService.showSheet = true
        }
    }

    func logout() {
        // Log out the user
        oauthService.logout()
        isAuthenticated = false
    }
}
