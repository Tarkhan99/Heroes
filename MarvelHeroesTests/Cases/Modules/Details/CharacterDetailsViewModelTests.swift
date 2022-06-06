//
//  CharacterDetailsViewModelTests.swift
//  MarvelHeroesTests
//
//  Created by Tarkhan Tahirov on 07.06.22.
//

import Quick
import Nimble
@testable import MarvelHeroes

class CharactersDetailsModelTests: QuickSpec {
    
    override func spec() {
        
        var sut: CharacterDetailsViewModel!
        var character: Character!
        
        beforeEach {
            let characterData = try! Data.fromJSON(fileName: "Character")
            character = try! JSONDecoder().decode(Character.self, from: characterData)
            sut = CharacterDetailsViewModel(character: character)
        }
        
        afterEach {
            character = nil
            sut = nil
        }
        
        describe("details view model") {
            
            context("when initialized") {
                
                it("sets name") {
                    expect(sut.characterName).to(equal(character.name))
                }
                
                it("sets description") {
                    expect(sut.characterDescription).to(equal(character.description))
                }
                
                it("sets image url") {
                    expect(sut.characterImageURL).to(equal(character.thumbnail?.url))
                }
                
            }
            
        }
        
    }
    
}
