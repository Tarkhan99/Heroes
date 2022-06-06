//
//  MockMarvelImageClient.swift
//  MarvelHeroesTests
//
//  Created by Tarkhan Tahirov on 07.06.22.
//

import Foundation
@testable import MarvelHeroes
import UIKit

class MockMarvelImageClient: ImageService {
    
    func loadImage(fromURL url: URL, completion: @escaping (UIImage?, Error?) -> ()) -> URLSessionTaskProtocol? {
        return nil
    }
    
    var receivedImageView: UIImageView!
    var receivedImageURL: URL?
    func setImage(fromURL url: URL?, imageView: UIImageView) {
        receivedImageView = imageView
        receivedImageURL = url
    }
    
    
}
