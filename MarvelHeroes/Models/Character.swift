//
//  MarvelCaracter.swift
//  MarvelHeroes
//
//  Created by Tarkhan Tahirov on 05.06.22.
//

import Foundation

struct Character: Decodable, Equatable {
    var id: Int64
    var name: String?
    var description: String?
    var thumbnail: Image?
    var series: CharacterItemsResponse?
    var comics: CharacterItemsResponse?
    var stories: CharacterItemsResponse?
}

struct CharacterItemsResponse: Decodable, Equatable {
    
    var items: [Item]?
    
    struct Item: Decodable, Equatable {
        var name: String?
        var resourceURI: String?
        var type: String?
    }
}
