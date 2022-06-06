//
//  CharacterCellViewModel.swift
//  MarvelHeroes
//
//  Created by Tarkhan Tahirov on 05.06.22.
//

import Foundation

protocol CharacterCellViewModelType {
    
    var name: String?  { get }
    var description: String? { get }
    var imageURL: URL? { get }
    
}

class CharacterCellViewModel: CharacterCellViewModelType {
    
    var name: String?
    var description: String?
    var imageURL: URL?
    
    init(character: Character) {
        self.name = character.name
        self.description = character.description
        self.imageURL = character.thumbnail?.url
    }
    
}
