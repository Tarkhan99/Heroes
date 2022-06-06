//
//  CharacterDetailsViewModel.swift
//  MarvelHeroes
//
//  Created by Tarkhan Tahirov on 07.06.22.
//

import Foundation

protocol CharacterDetailsViewModelType {
    
    var characterName: String? { get }
    var characterDescription: String? { get }
    var characterImageURL: URL? { get }
    var tableDataSource: [(String, [CharacterItemsResponse.Item])] { get }
    
}

class CharacterDetailsViewModel: CharacterDetailsViewModelType {
    
    var characterName: String?
    var characterDescription: String?
    var characterImageURL: URL?
    var tableDataSource: [(String, [CharacterItemsResponse.Item])] = []
    
    init(character: Character?) {
        self.characterName = character?.name
        self.characterDescription = character?.description
        self.characterImageURL = character?.thumbnail?.url
        if let comics = character?.comics?.items, !comics.isEmpty {
            tableDataSource.append(("Comics", comics))
        }
        if let series = character?.series?.items, !series.isEmpty {
            tableDataSource.append(("Series", series))
        }
        if let stories = character?.stories?.items, !stories.isEmpty {
            tableDataSource.append(("Stories", stories))
        }
    }
    
}
