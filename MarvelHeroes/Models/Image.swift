//
//  Image.swift
//  MarvelHeroes
//
//  Created by Tarkhan Tahirov on 05.06.22.
//

import Foundation

struct Image: Decodable, Equatable {
    
    let path: String?
    let ext: String?
    
    enum CodingKeys: String, CodingKey {
        case path
        case ext = "extension"
    }
    
}

extension Image {
    
    var url: URL? {
        if let path = path, let ext = ext {
            var imageURLString = "\(path).\(ext)"
            imageURLString = "https" + imageURLString.dropFirst(4)
            return URL(string: imageURLString)
        }
        return nil
    }
    
}
