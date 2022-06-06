//
//  URLSessionProtocol.swift
//  MarvelHeroes
//
//  Created by Tarkhan Tahirov on 06.06.22.
//

import Foundation

protocol URLSessionProtocol: AnyObject {
    func makeDataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol
}

protocol URLSessionTaskProtocol: AnyObject {
    func resume()
    func cancel()
}

extension URLSessionTask: URLSessionTaskProtocol {
    
}

extension URLSession: URLSessionProtocol {
    func makeDataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol
    {
        return dataTask(with: url, completionHandler: completionHandler)
    }
}
