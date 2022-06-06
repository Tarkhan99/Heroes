//
//  CharactersListViewModelTests.swift
//  MarvelHeroesTests
//
//  Created by Tarkhan Tahirov on 05.06.22.
//

import Quick
import Nimble
@testable import MarvelHeroes

class CharactersListViewModelTests: QuickSpec {
    
    override func spec() {
        
        var sut: CharactersListViewModel!
        var mockNetworkClient: MockMarvelNetworkClient!
        
        beforeEach {
            mockNetworkClient = MockMarvelNetworkClient()
            sut = CharactersListViewModel(with: mockNetworkClient)
        }
        
        afterEach {
            mockNetworkClient = nil
            sut = nil
        }
        
        describe("CharactersListViewModel") {
            it("conforms to CharactersListViewModelType") {
                expect(sut).to(beAKindOf(CharactersListViewModelType.self))
            }
            
            it("when initialized sets CharactersService") {
                expect((sut.charactersService as AnyObject) === mockNetworkClient).to(beTrue())
            }
            
            context("when fetch episodes called") {
                
                beforeEach {
                    sut.fetchCharacters()
                }
                
                it("calls CharacterService fetchCharacters") {
                    expect(mockNetworkClient.isFetchCharactersCalled).to(beTrue())
                }
                
                it("when fetch failed sets errorMessage") {
                    enum MockError: Error, LocalizedError {
                        case error
                        
                        var errorDescription: String? {
                            return "Mock error description"
                        }
                    }
                    let expectedError = MockError.error
                    
                    mockNetworkClient.fetchFail(error: expectedError)
                    
                    expect(sut.errorMessage).to(equal(expectedError.errorDescription))
                }
                
                it("when fetch success sets cellViewModels") {
                    let data = try! Data.fromJSON(fileName: "CharactersListResponse")
                    mockNetworkClient.completionResponse = try! JSONDecoder().decode(CharactersResponse.self, from: data)
                    
                    mockNetworkClient.fetchSuccess()
                    
                    expect(sut.charactersResponse).to(equal(mockNetworkClient.completionResponse))
                }
                
            }
            
            context("load more characters") {
                
                beforeEach {
                    let data = try! Data.fromJSON(fileName: "CharactersListResponse")
                    mockNetworkClient.completionResponse = try! JSONDecoder().decode(CharactersResponse.self, from: data)
                    
                    sut.fetchCharacters()
                    mockNetworkClient.fetchSuccess()
                }
                
                afterEach {
                    mockNetworkClient.completionResponse = nil
                }
                
                it("increases page count") {
                    let pageCountBefore = sut.page
                    
                    sut.loadMoreCharacters()
                    
                    expect(sut.page).to(equal(pageCountBefore+1))
                }
                
                it("calls CharacterService fetchCharacters") {
                    sut.loadMoreCharacters()
                    
                    expect(mockNetworkClient.isFetchCharactersCalled).to(beTrue())
                }
                
                it("when fetch failed sets errorMessage") {
                    enum MockError: Error, LocalizedError {
                        case error
                        
                        var errorDescription: String? {
                            return "Mock error description"
                        }
                    }
                    let expectedError = MockError.error
                    
                    sut.loadMoreCharacters()
                    mockNetworkClient.fetchFail(error: expectedError)
                    
                    expect(sut.errorMessage).to(equal(expectedError.errorDescription))
                }
                
                it("when fetch success appends to cell view models") {
                    let data = try! Data.fromJSON(fileName: "CharactersListResponse")
                    mockNetworkClient.completionResponse = try! JSONDecoder().decode(CharactersResponse.self, from: data)
                    
                    sut.loadMoreCharacters()
                    mockNetworkClient.fetchSuccess()
                    
                    let limit = 4
                    let newResponseCount = mockNetworkClient.completionResponse?.data?.results?.count ?? 0
                    expect(sut.cellViewModels.count).to(equal(sut.page*limit+newResponseCount))
                }
                
            }
        }
        
        
    }
    
}
