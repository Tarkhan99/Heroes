//
//  MockNetworkClient.swift
//  MarvelHeroesTests
//
//  Created by Tarkhan Tahirov on 06.06.22.
//

@testable import MarvelHeroes
import Foundation

class MockURLSession: URLSessionProtocol {
    
    var queue: DispatchQueue? = nil
    
    func givenDispatchQueue() {
      queue = DispatchQueue(label: "com.mockSession")
    }
    
    func makeDataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionTaskProtocol {
        return MockURLSessionTask(url: url, completionHandler: completionHandler, queue: queue)
    }
    
}

class MockURLSessionTask: URLSessionTaskProtocol {
    
    var url: URL
    var completionHandler: (Data?, URLResponse?, Error?) -> Void
    
    init(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void, queue: DispatchQueue?) {
        self.url = url
        if let queue = queue {
          self.completionHandler = { data, response, error in
            queue.async() {
              completionHandler(data, response, error)
            }
          }
        } else {
          self.completionHandler = completionHandler
        }
    }
    
    var calledCancel = false
    func cancel() {
        calledCancel = true
    }
    
    var calledResume = false
    func resume() {
        calledResume = true
    }
    
}
