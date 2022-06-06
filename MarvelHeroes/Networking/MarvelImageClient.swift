//
//  MarvelImageClient.swift
//  MarvelHeroes
//
//  Created by Tarkhan Tahirov on 06.06.22.
//

import UIKit

protocol ImageService {
    func loadImage(fromURL url: URL, completion: @escaping (UIImage?, Error?) -> ()) -> URLSessionTaskProtocol?
    func setImage(fromURL url: URL?, imageView: UIImageView)
}

class MarvelImageClient: ImageService {
    
    static let shared = MarvelImageClient(session: URLSession.shared, responseQueue: .main)
    
    var session: URLSessionProtocol
    var responseQueue: DispatchQueue?
    
    var imageCacheForURL: [URL: UIImage]
    var taskCacheForImageView: [UIImageView: URLSessionTaskProtocol]
    
    init(session: URLSessionProtocol, responseQueue: DispatchQueue?) {
        self.session = session
        self.responseQueue = responseQueue
        
        imageCacheForURL = [:]
        taskCacheForImageView = [:]
    }
    
    func loadImage(fromURL url: URL, completion: @escaping (UIImage?, Error?) -> ()) -> URLSessionTaskProtocol? {
        
        if let cachedImage = imageCacheForURL[url] {
            completion(cachedImage, nil)
            return nil
        }
        
        let task = session.makeDataTask(with: url) { [weak self] data, response, error in
            
            if let data = data, let image = UIImage(data: data) {
                self?.imageCacheForURL[url] = image
                self?.dispatchResult(image: image, completion: completion)
            } else {
                self?.dispatchResult(error: error, completion: completion)
            }
            
        }
        
        task.resume()
        
        return task
    }
    
    func setImage(fromURL url: URL?, imageView: UIImageView) {
        guard let url = url else { return }
        
        taskCacheForImageView[imageView]?.cancel()
        
        taskCacheForImageView[imageView] = loadImage(fromURL: url, completion: { [weak self] image, error in
            self?.taskCacheForImageView[imageView] = nil
            imageView.image = image
        })

    }
    
    private func dispatchResult(image: UIImage? = nil, error: Error? = nil, completion: @escaping (UIImage?, Error?) -> Void) {
      guard let responseQueue = responseQueue else {
        completion(image, error)
        return
      }
      responseQueue.async {
        completion(image, error)
      }
    }
    
}
