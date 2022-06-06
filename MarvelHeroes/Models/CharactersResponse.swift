//
//  CharactersResponse.swift
//  MarvelHeroes
//
//  Created by Tarkhan Tahirov on 06.06.22.
//

import Foundation

struct CharactersResponse: Decodable, Equatable {
    var code: Int?
    var status: String?
    var data: CharactersDataResponse?
}

struct CharactersDataResponse: Decodable, Equatable {
    var offset: Int?
    var limit: Int?
    var total: Int?
    var count: Int?
    var results: [Character]?
}
