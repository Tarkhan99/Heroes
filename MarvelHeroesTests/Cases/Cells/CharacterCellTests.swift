//
//  CharacterCellTests.swift
//  MarvelHeroesTests
//
//  Created by Tarkhan Tahirov on 05.06.22.
//

import Quick
import Nimble
@testable import MarvelHeroes

class CharacterCellTests: QuickSpec {
    
    override func spec() {
        
        var sut: CharacterCell!
        var mockViewModel: MockCharacterCellViewModel!
        var mockImageService: MockMarvelImageClient!
        
        beforeEach {
            mockImageService = MockMarvelImageClient()
            mockViewModel = MockCharacterCellViewModel()
            sut = CharacterCell()
            sut.imageService = mockImageService
        }
        
        afterEach {
            mockImageService = nil
            mockViewModel = nil
            sut = nil
        }
        
        describe("character cell") {
            
            it("init with coder sets sut to nil") {
                sut = CharacterCell(coder: NSCoder())
                expect(sut).to(beNil())
            }
            
            context("configure cell") {
                
                beforeEach {
                    sut.configure(with: mockViewModel)
                }
                
                it("sets name label text") {
                    expect(sut.nameLabel.text).to(equal(mockViewModel.name))
                }
                
                it("sets description label text") {
                    expect(sut.descriptionLabel.text).to(equal(mockViewModel.description))
                }
                
                it("calls set image with imageview and url") {
                    expect(mockImageService.receivedImageView).to(equal(sut.imageView))
                    expect(mockImageService.receivedImageURL).to(equal(mockViewModel.imageURL))
                }
            }
            
        }
        
    }
    
}

class MockCharacterCellViewModel: CharacterCellViewModelType {
    
    var name: String?
    var description: String?
    var imageURL: URL?
    
    init() {
        name = "Character name"
        description = "Character name"
        imageURL = URL(string: "http://i.annihil.us/u/prod/marvel/i/mg/3/20/5232158de5b16.jpg")
    }
    
}
