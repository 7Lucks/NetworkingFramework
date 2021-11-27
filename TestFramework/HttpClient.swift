//
//  HttpClient.swift
//  TestFrameworkTests
//
//  Created by Дмитрий Игнатьев on 27.11.2021.
//

import UIKit

//MARK: - Protocols-
protocol NetworkRequest{
    func resume()
}

extension URLSessionDataTask: NetworkRequest{
}

protocol NetworkSession{
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkRequest
}

//MARK: - Classes-

class URLSessionHttpClient{
    private struct UnexpectedArguments: Error {}
    private let session: NetworkSession
    
    init(session: NetworkSession){
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> ()){
        
        let dataTask = session.dataTask(with: url){data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let response = response as? HTTPURLResponse, let data = data {
                completion(.success((data, response)))
            }else{
                completion(.failure(UnexpectedArguments()))
            }
        }
        dataTask.resume()
    }
}
