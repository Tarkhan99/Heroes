//
//  CharacterCellVMTests.swift
//  MarvelHeroesTests
//
//  Created by Tarkhan Tahirov on 05.06.22.
//

import Quick
import Nimble
@testable import MarvelHeroes

class CharacterCellViewModelTests: QuickSpec {
    
    override func spec() {
        
        var sut: CharacterCellViewModel!
        var character: Character!
        
        beforeEach {
            let characterData = try! Data.fromJSON(fileName: "Character")
            character = try! JSONDecoder().decode(Character.self, from: characterData)
            sut = CharacterCellViewModel(character: character)
        }
        
        afterEach {
            character = nil
            sut = nil
        }
        
        describe("CharacterCellViewModel") {
            
            it("conforms to CharacterCellViewModelType") {
                expect(sut).to(beAKindOf(CharacterCellViewModelType.self))
            }
            
            context("when initialized with character") {
                
                it("sets name") {
                    expect(sut.name).to(equal(character.name))
                }
                
                it("sets description") {
                    expect(sut.description).to(equal(character.description))
                }
                
                it("sets imageURL") {
                    expect(sut.imageURL).to(equal(character.thumbnail?.url))
                }
                
            }
        }
        
    }
    
}
