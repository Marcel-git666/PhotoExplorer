//
//  Fakes.swift
//  PhotoExplorerTests
//
//  Created by Marcel Mravec on 09.10.2023.
//

import Foundation

class URLSessionDataTaskMock: URLSessionDataTask {
    private let data: Data?
    private let urlResponse: URLResponse?
    private let sessionError: Error?
    
    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    
    init(data: Data?, urlResponse: URLResponse?, error: Error?) {
        self.data = data
        self.urlResponse = urlResponse
        self.sessionError = error
    }
    
    override func resume() {
        completionHandler?(data, urlResponse, sessionError)
    }
}



class URLSessionMock: URLSession {
    var mockData: Data?
    var mockError: Error?
    var mockURLResponse: URLResponse?

    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let dataTask = URLSessionDataTaskMock(data: mockData, urlResponse: mockURLResponse, error: mockError)
        dataTask.completionHandler = completionHandler
        return dataTask
    }
}
