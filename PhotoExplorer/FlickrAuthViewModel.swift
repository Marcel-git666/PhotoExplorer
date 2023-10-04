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
    private var flickrOAuthService: FlickrOAuthService
    
    var authUrl: URL? {
        return flickrOAuthService.authUrl
    }
    
    init(flickrOAuthService: FlickrOAuthService) {
        self.flickrOAuthService = flickrOAuthService
        
        // Subscribe to authenticationState changes from FlickrOAuthService
        self.flickrOAuthService.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    // Add functions to handle authorization and logout if needed
    // For example:
    func authorize() {
        flickrOAuthService.authorize()
    }
    
    func logout() {
        flickrOAuthService.logout()
    }
    
    private var cancellables = Set<AnyCancellable>()
}
