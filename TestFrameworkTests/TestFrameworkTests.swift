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

//MARK: - Testing -

class TestFrameworkTests: XCTestCase{
    
    func test_get_Invalid_Result_On_Nil_Error_Response_Data(){
        
        let sut = URLSessionHttpClient(session: NetworkSessionSpy())
        let url = URL(string: "https://google.com")!
        let exp = expectation(description: "Waiting for response")
        
        sut.get(from: url){ result in
            
            switch result{
            case .failure:
                exp.fulfill()
            default:
                XCTFail("Unexpected failure")
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    
    
    
    
    
    
    
    
    
}
