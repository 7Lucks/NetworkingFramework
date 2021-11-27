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
    
    //MARK: -  Invalid result with all nil data, response, error
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
    //MARK: -  Invalid result on nil data with response
    func test_get_Invalid_Result_On_Nil_Date_With_Response(){
        
        let url = URL(string: "https://google.com")!
        let spy = NetworkSessionSpy()
        let request = NetworkRequestSpy()
        
        //MARK: requests
        request.data = nil
        //MARK: response
        let myResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        spy.request = request
        
        let sut = URLSessionHttpClient(session: spy)
        let exp = expectation(description: "Waiting for response")
        
        sut.get(from: url){result in
            
            switch result{
            case .failure:
                exp.fulfill()
            default:
                XCTFail("Unexpected failure")
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Enum with some error -
    enum SomeError: Error{
        case networkErr
    }
    
    //MARK: - Valid data with received error
    func test_get_Valid_Result_On_Received_Error(){
        
        let url = URL(string: "https://google.com")!
        let spy = NetworkSessionSpy()
        let request = NetworkRequestSpy()
        
        //MARK: requests
        request.data = nil
        request.response = nil
        request.error = SomeError.networkErr
        spy.request = request
        
        let sut = URLSessionHttpClient(session: spy)
        let exp = expectation(description: "Waiting for response")
        
        sut.get(from: url){ result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as? SomeError, SomeError.networkErr)
                exp.fulfill()
            default:
                XCTFail("Unexpected failure")
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    //MARK: - Valid result on valid Data and Response
    func test_get_Valid_Result_On_Valid_Data_Response(){
        
        let url = URL(string: "https://google.com")!
        let myData = Data()
        let spy = NetworkSessionSpy()
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        var request = NetworkRequestSpy()
        
        //MARK: requests
        request.data = myData
        request.response = response
        request.error = nil
        spy.request = request
        
        let sut = URLSessionHttpClient(session: spy)
        let exp = expectation(description: "Waiting for response")
        
        sut.get(from: url) { result in
            switch result{
            case let .success(data, myResponse):
                XCTAssertEqual(myData, data)
                XCTAssertEqual(myResponse, response)
                exp.fulfill()
            default:
                XCTFail("Unexpected failure")
            }
            
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: -  invalid result with valid data without response
    func test_get_Invalid_Result_On_Valid_Data_Response(){
        
        let url = URL(string: "https://google.com")!
        let myData = Data()
        let spy = NetworkSessionSpy()
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        var request = NetworkRequestSpy()
        
        //MARK: requests
        request.data = myData
        request.response = nil
        request.error = nil
        spy.request = request
        
        let sut = URLSessionHttpClient(session: spy)
        let exp = expectation(description: "Waiting for response")
        
        sut.get(from: url) { result in
            
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
