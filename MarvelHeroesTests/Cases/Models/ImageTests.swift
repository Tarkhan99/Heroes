//
//  ImageTests.swift
//  MarvelHeroesTests
//
//  Created by Tarkhan Tahirov on 05.06.22.
//

import Quick
import Nimble
@testable import MarvelHeroes

class ImageTests: QuickSpec {
        
    override func spec() {
        
        var sut: Image!
        
        beforeEach {
            sut = Image(path: "http://i.annihil.us", ext: "jpg")
        }
        
        afterEach {
            sut = nil
        }
        
        describe("image") {
            
            context("conforms to") {
                
                it("decodable") {
                    expect(sut).to(beAKindOf(Decodable.self))
                }
                
                it("equatable") {
                    expect(sut).to(beAKindOf(Equatable.self))
                }
                
            }
            
            context("when one of properties is nil") {
                
                it("url also is nil") {
                    sut = Image(path: nil, ext: "ext")
                    expect(sut.url).to(beNil())
                    
                    sut = Image(path: "path", ext: nil)
                    expect(sut.url).to(beNil())
                }
                
            }
            
            it("url returns as expected") {
                let expectedURL = URL(string: "https://i.annihil.us.jpg")
                expect(sut.url).to(equal(expectedURL))
            }
            
        }
        
        describe("decodable sets") {
            
            it("path") {
                expect(sut.path).to(equal("http://i.annihil.us"))
            }
            
            it("extension") {
                expect(sut.ext).to(equal("jpg"))
            }
            
        }
                
    }
    
}
