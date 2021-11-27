//
//  TestFrameworkTests.swift
//  TestFrameworkTests
//
//  Created by Дмитрий Игнатьев on 14.11.2021.
//

import XCTest
@testable import TestFramework


//MARK: - request spy -
class NetworkRequestSpy: NetworkRequest{
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    var completion: ((Data?, URLResponse?, Error?) -> Void)?
    
    func resume() {
        completion?(data, response, error)
    }
}
//MARK: -  session spy -
class NetworkSessionSpy: NetworkSession{
    
    var request: NetworkRequestSpy = NetworkRequestSpy()
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkRequest {
        request.completion = completionHandler
        return request
    }
}
