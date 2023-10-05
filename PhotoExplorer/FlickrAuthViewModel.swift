//
//  FlickrAuthViewModel.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 03.10.2023.
//

import Foundation
import Combine

class FlickrAuthViewModel: ObservableObject {
    @Published var authenticationState: AuthenticationState = .noAuthenticationAttempted
    @Published var isAuthenticationCompleted = false
    @Published var credential: FlickrOAuthService.RequestAccessTokenResponse?
    @Published var shouldNavigateToSafari = false

    private var flickrOAuthService: FlickrOAuthService
    
    var authUrl: URL? {
        return flickrOAuthService.authUrl
    }
    
    init(flickrOAuthService: FlickrOAuthService) {
        self.flickrOAuthService = flickrOAuthService
        // Subscribe to authenticationState changes from FlickrOAuthService
        self.flickrOAuthService.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
            if self?.flickrOAuthService.authenticationState == .successfullyAuthenticated {
                self?.isAuthenticationCompleted = true
            }
        }.store(in: &cancellables)
    }
    
    // Add functions to handle authorization and logout if needed
    // For example:
    func authorize() {
        flickrOAuthService.authorize()
    }
    
    func handleOAuthCallback(url: URL) {
            flickrOAuthService.handleOAuthCallback(url: url) { [weak self] result in
                switch result {
                case .success(let accessTokenResponse):
                    // Authentication successful, handle the credential
                    print("Authentication successful: \(accessTokenResponse)")
                    // Update your ViewModel's properties or perform any necessary actions
                    self?.authenticationState = .successfullyAuthenticated
                    self?.isAuthenticationCompleted = true
                    // Handle accessTokenResponse if needed
                case .failure(let error):
                    // Handle the authentication failure
                    print("Authentication failed: \(error)")
                    // Update your ViewModel's properties or perform any necessary actions to indicate failure
                    self?.authenticationState = .failedAuthentication
                }
            }
        }




    
    func getUserPhotos(completion: @escaping (Result<Data, Error>) -> Void) {
        flickrOAuthService.getUserPhotos(completion: completion)
    }
    
    
    func logout() {
        flickrOAuthService.logout()
    }
    
    private var cancellables = Set<AnyCancellable>()
}
