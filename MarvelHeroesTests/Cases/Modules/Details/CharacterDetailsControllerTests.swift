//
//  CharacterDetailsControllerTests.swift
//  MarvelHeroesTests
//
//  Created by Tarkhan Tahirov on 07.06.22.
//

import Quick
import Nimble
@testable import MarvelHeroes

class CharacterDetailsViewControllerTests: QuickSpec {
    
    override func spec() {
        
        var sut: CharacterDetailsViewController!
        var mockViewModel: MockCharacterDetailsViewModel!
        var mockImageService: MockMarvelImageClient!
        
        beforeEach {
            mockImageService = MockMarvelImageClient()
            mockViewModel = MockCharacterDetailsViewModel()
            sut = CharacterDetailsViewController(with: mockViewModel, imageService: mockImageService)
        }
        
        afterEach {
            mockImageService = nil
            mockViewModel = nil
            sut = nil
        }
        
        describe("details view controller") {
            
            it("init sets view model") {
                expect(sut.viewModel).toNot(beNil())
                expect(sut.viewModel).to(beAKindOf(CharacterDetailsViewModelType.self))
                expect((sut.viewModel as AnyObject) === mockViewModel).to(beTrue())
            }
            
            it("init sets image service") {
                expect(sut.imageService).toNot(beNil())
                expect(sut.imageService).to(beAKindOf(ImageService.self))
                expect((sut.imageService as AnyObject) === mockImageService).to(beTrue())
            }
            
            it("init with coder sets sut to nil") {
                sut = CharacterDetailsViewController(coder: NSCoder())
                expect(sut).to(beNil())
            }
            
            
            context("view did load") {
                
                beforeEach {
                    sut.viewDidLoad()
                }
                
                it("creates subviews") {
                    expect(sut.view.subviews.contains(sut.descriptionLabel)).to(beTrue())
                    expect(sut.view.subviews.contains(sut.characterImageView)).to(beTrue())
                    expect(sut.view.subviews.contains(sut.detailsTableView)).to(beTrue())
                }
                
                it("sets navigation title") {
                    expect(sut.title).to(equal(mockViewModel.characterName))
                }
                
                it("sets description label text") {
                    expect(sut.descriptionLabel.text).to(equal(mockViewModel.characterDescription))
                }
                
                it("calls set image with imageview and url") {
                    expect(mockImageService.receivedImageView).to(equal(sut.characterImageView))
                    expect(mockImageService.receivedImageURL).to(equal(mockViewModel.characterImageURL))
                }
                
                it("header for section returns expected string") {
                    for i in 0..<mockViewModel.tableDataSource.count {
                        let expected = mockViewModel.tableDataSource[i].0
                        let actual = sut.tableView(sut.detailsTableView, titleForHeaderInSection: i)
                        expect(actual).to(equal(expected))
                    }
                }
                
                it("number of sections returns as expected") {
                    let expected = mockViewModel.tableDataSource.count
                    let actual = sut.numberOfSections(in: sut.detailsTableView)
                    expect(actual).to(equal(expected))
                }
                
                it("number of rows in sections returns expected") {
                    for i in 0..<mockViewModel.tableDataSource.count {
                        let expected = mockViewModel.tableDataSource[i].1.count
                        let actual = sut.tableView(sut.detailsTableView, numberOfRowsInSection: i)
                        expect(actual).to(equal(expected))
                    }
                }
                
                it("cell for row at configures cell") {
                    for section in 0..<mockViewModel.tableDataSource.count {
                        for row in 0..<mockViewModel.tableDataSource[section].1.count {
                            let indexPath = IndexPath(row: row, section: section)
                            let cell = sut.tableView(sut.detailsTableView, cellForRowAt: indexPath)
                            expect(cell.backgroundColor).to(equal(.clear))
                            let expectedLabel = mockViewModel.tableDataSource[section].1[row].name
                            expect(cell.textLabel?.text).to(equal(expectedLabel))
                        }
                    }
                }
                
            }
            
        }
        
    }
    
}

class MockCharacterDetailsViewModel: CharacterDetailsViewModelType {
    
    var characterName: String?
    
    var characterDescription: String?
    
    var characterImageURL: URL?
    
    var tableDataSource: [(String, [CharacterItemsResponse.Item])] = []
    
    init() {
        let characterData = try! Data.fromJSON(fileName: "Character")
        let character = try? JSONDecoder().decode(Character.self, from: characterData)
        
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
