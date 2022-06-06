//
//  CharacterTests.swift
//  MarvelHeroesTests
//
//  Created by Tarkhan Tahirov on 05.06.22.
//

import Quick
import Nimble
@testable import MarvelHeroes

class CharacterTests: QuickSpec, DecodableTestCase {
    
    var sut: Character!
    
    override func spec() {
        
        var sut: Character!
        
        beforeEach {
            try! self.givenSUTFromJSON()
            sut = self.sut
        }
        
        afterEach {
            self.sut = nil
            sut = nil
        }
        
        describe("a character") {
            
            context("conforms to") {
                
                it("decodable") {
                    expect(sut).to(beAKindOf(Decodable.self))
                }
                
                it("equatable") {
                    expect(sut).to(beAKindOf(Equatable.self))
                }
                
            }
            
        }
        
        describe("decodable") {
            
            it("sets id") {
                expect(sut.id).to(equal(1017100))
            }
            
            it("sets name") {
                expect(sut.name).to(equal("A-Bomb (HAS)"))
            }
            
            it("sets description") {
                expect(sut.description).to(equal("Description"))
            }
            
            it("sets thumbnail") {
                let expected = Image(path: "http://i.annihil.us/u/prod/marvel/i/mg/3/20/5232158de5b16", ext: "jpg")
                expect(sut.thumbnail).to(equal(expected))
            }
            
        }
        
    }
    
}
