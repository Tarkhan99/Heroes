//
//  MarvelCharactersClient.swift
//  MarvelHeroes
//
//  Created by Tarkhan Tahirov on 06.06.22.
//

import Foundation
import CryptoKit

protocol CharactersService {
    func fetchCharacters(query: String?,
                         page: Int,
                         completion: @escaping (CharactersResponse?, Error?) -> ()
    ) -> URLSessionTaskProtocol?
}


class MarvelNetworkClient: CharactersService {
    
    static let shared = MarvelNetworkClient(
        baseURL:  URL(string: "https://gateway.marvel.com/")!,
        session: URLSession.shared,
        responseQueue: .main,
        publicKey: "0136401a212a379949917b69ed604f9f",
        privateKey: "efcfe242f5c5ac6ab695a9d8994726316a3fe5dd"
    )
    
    var baseURL: URL
    var session: URLSessionProtocol
    var responseQueue: DispatchQueue?
    var publicKey: String
    var privateKey: String
    
    init(baseURL: URL, session: URLSessionProtocol, responseQueue: DispatchQueue?, publicKey: String, privateKey: String) {
        self.baseURL = baseURL
        self.session = session
        self.responseQueue = responseQueue
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
    
    func fetchCharacters(query: String?,
                         page: Int,
                         completion: @escaping (CharactersResponse?, Error?) -> ()
    ) -> URLSessionTaskProtocol? {
        
        var components = URLComponents(
            url: baseURL.appendingPathComponent("v1/public/characters"),
            resolvingAgainstBaseURL: true
        )
        
        let timestamp: TimeInterval = Date().timeIntervalSince1970
        
        var queryItems = [
            URLQueryItem(name: "ts", value: "\(timestamp)"),
            URLQueryItem(name: "hash", value: generateAPIHash(timestamp: timestamp)),
            URLQueryItem(name: "apikey", value: publicKey)
        ]
        
        if let searchQuery = query {
            queryItems.append(URLQueryItem(name: "nameStartsWith", value: searchQuery))
        }
        
        queryItems.append(URLQueryItem(name: "offset", value: "\(page*20)"))
        
        components?.queryItems = queryItems
                
        let urlWithQueries = (components?.url)!
        
        print(urlWithQueries)
        
        let task = session.makeDataTask(with: urlWithQueries) { [weak self] data, response, error in
            
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  error == nil,
                  let data = data
            else {
                self?.dispatchResult(error: error, completion: completion)
                return
            }
            
            do {
                let charactersResponse = try JSONDecoder().decode(CharactersResponse.self, from: data)
                self?.dispatchResult(model: charactersResponse, completion: completion)
            } catch {
                self?.dispatchResult(error: error, completion: completion)
            }
            
        }
        
        task.resume()
        
        return task
    }
    
    private func dispatchResult<T>(model: T? = nil,error: Error? = nil, completion: @escaping (T?, Error?) -> Void) {
      guard let responseQueue = responseQueue else {
        completion(model, error)
        return
      }
      responseQueue.async {
        completion(model, error)
      }
    }
    
    func generateAPIHash(timestamp: TimeInterval = Date().timeIntervalSince1970) -> String {
        let hashValue = "\(timestamp)\(privateKey)\(publicKey)"
        let digest = Insecure.MD5.hash(data: hashValue.data(using: .utf8) ?? Data())
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
}
