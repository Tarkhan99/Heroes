//
//  CharactersViewControllerTests.swift
//  MarvelHeroesTests
//
//  Created by Tarkhan Tahirov on 05.06.22.
//

import Quick
import Nimble
@testable import MarvelHeroes

class CharactersViewControllerTests: QuickSpec {
    
    override func spec() {
        
        var navigationController: UINavigationController!
        var sut: CharactersViewController!
        var mockViewModel: MockCharactersListViewModel!
        
        beforeEach {
            mockViewModel = MockCharactersListViewModel()
            sut = CharactersViewController(with: mockViewModel)
            navigationController = UINavigationController(rootViewController: sut)
        }
        
        afterEach {
            mockViewModel = nil
            sut = nil
            navigationController = nil
        }
        
        describe("characters list controller") {
            it("init sets view model") {
                expect(sut.viewModel).toNot(beNil())
                expect(sut.viewModel).to(beAKindOf(CharactersListViewModelType.self))
                expect((sut.viewModel as AnyObject) === mockViewModel).to(beTrue())
            }
            
            it("init with coder sets sut to nil") {
                sut = CharactersViewController(coder: NSCoder())
                expect(sut).to(beNil())
            }
            
            context("view did load") {
                
                beforeEach {
                    sut.viewDidLoad()
                }
                
                it("calls fetchCharacters") {
                    expect(mockViewModel.isFetchCharactersCalled).to(beTrue())
                }
                
                it("setups search controller") {
                    expect(sut.navigationItem.searchController === sut.searchController).to(beTrue())
                    let delegateTarget = sut.searchController.searchBar.delegate as! CharactersViewController
                    expect(delegateTarget === sut).to(beTrue())
                }
                
            }
            
            context("when search button clicked") {
               
                beforeEach {
                    sut.setupSearchController()
                    sut.searchController.searchBar.text = "query"
                    let searchBar = sut.searchController.searchBar
                    searchBar.delegate?.searchBarSearchButtonClicked?(searchBar)
                }
                
                it("sets search query") {
                    expect(mockViewModel.searchQuery).to(equal("query"))
                }
                
                it("calls fetch characters") {
                    expect(mockViewModel.isFetchCharactersCalled).to(beTrue())
                }
                
            }
            
            context("when cancel search clicked") {
                
                beforeEach {
                    sut.setupSearchController()
                    let searchBar = sut.searchController.searchBar
                    searchBar.delegate?.searchBarCancelButtonClicked?(searchBar)
                }
                
                it("sets search query to nil") {
                    expect(mockViewModel.searchQuery).to(beNil())
                }
                
                it("calls fetch characters") {
                    expect(mockViewModel.isFetchCharactersCalled).to(beTrue())
                }
                
            }
            
            context("collection view") {
                
                beforeEach {
                    sut.setupCollectionView()
                }
                
                it("numberOfItems returns cell vms count") {
                    let itemsCount = sut.collectionView(sut.collectionView, numberOfItemsInSection: 0)
                    expect(itemsCount).to(equal(mockViewModel.cellViewModels.count))
                }
                
                context("cellForRowAt for given view model set") {
                    
                    var cells: [UICollectionViewCell]!
                    
                    beforeEach {
                        mockViewModel.givenCellViewModels()
                        cells = (0 ..< mockViewModel.cellViewModels.count).map { i in
                            let indexPath = IndexPath(row: i, section: 0)
                            return sut.collectionView(sut.collectionView, cellForItemAt: indexPath)
                        }
                    }
                    
                    afterEach {
                        mockViewModel.cellViewModels = []
                        cells = nil
                    }
                    
                    it("returns CharacterCells") {
                        for cell in cells {
                            expect(cell).to(beAKindOf(CharacterCell.self))
                        }
                    }
                    
                    it("configures CharacterCell") {
                        let characterCells = cells as! [CharacterCell]
                        for i in 0 ..< characterCells.count {
                            let cell = characterCells[i]
                            let viewModel = mockViewModel.cellViewModels[i]
                            expect(cell.nameLabel.text).to(equal(viewModel.name))
                            expect(cell.descriptionLabel.text).to(equal(viewModel.description))
                        }
                    }
                }
                
                it("will display calls load more") {
                    mockViewModel.givenCellViewModels()
                    let indexPath = IndexPath(row: mockViewModel.cellViewModels.count-1, section: 0)
                    
                    sut.collectionView(sut.collectionView, willDisplay: UICollectionViewCell(), forItemAt: indexPath)
                    
                    expect(mockViewModel.isLoadMoreCalled).to(beTrue())
                }
                
                it("did select row at pushes details controller") {
                    mockViewModel.givenCellViewModels()
                    let indexPath = IndexPath(row: mockViewModel.cellViewModels.count-1, section: 0)

                    sut.collectionView(sut.collectionView, didSelectItemAt: indexPath)
                    
                    expect(sut.navigationController?.topViewController)
                        .toEventually(beAnInstanceOf(CharacterDetailsViewController.self), timeout: .milliseconds(500))
                }
                
            }
            
            context("setup view model") {
                
                beforeEach {
                    sut.setupViewModel()
                }
                
                it("reloadClosure reloads collection view") {
                    // given
                    class MockCollectionView: UICollectionView {
                        var calledReloadData = false
                        override func reloadData() {
                            calledReloadData = true
                        }
                    }
                    let mockCollectionView = MockCollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
                    sut.collectionView = mockCollectionView
                    
                    // when
                    mockViewModel.reloadCollectionView?()
                    
                    // then
                    expect(mockCollectionView.calledReloadData).to(beTrue())
                }
                
                it("updates loading status begins loading") {
                    mockViewModel.isLoading = true
                    mockViewModel.updateLoadingStatus?()
                    
                    expect(sut.activityIndicator.isAnimating).to(beTrue())
                }
                
                it("updates loading status ends loading") {
                    mockViewModel.isLoading = false
                    mockViewModel.updateLoadingStatus?()
                    
                    expect(sut.activityIndicator.isAnimating).to(beFalse())
                }
                
            }
            
            
            
            
        }
    
        
    }
    
}

class MockCharactersListViewModel: CharactersListViewModelType {
    
    var charactersResponse: CharactersResponse?
    
    var cellViewModels: [CharacterCellViewModelType] = []
    var errorMessage: String?
    var isLoading: Bool = false
    
    var page: Int = 0
    var searchQuery: String?
    
    var reloadCollectionView: (() -> ())?
    var showErrorAlertMessage: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    
    
    var isFetchCharactersCalled = false
    func fetchCharacters() {
        isFetchCharactersCalled = true
    }
    
    func givenCellViewModels(count: Int = 4) {
        let data = try! Data.fromJSON(fileName: "CharactersListResponse")
        charactersResponse = try? JSONDecoder().decode(CharactersResponse.self, from: data)
        
        cellViewModels = (charactersResponse?.data?.results ?? []).map { CharacterCellViewModel(character: $0) }
    }
    
    var isLoadMoreCalled = false
    func loadMoreCharacters() {
        isLoadMoreCalled = true
    }
    
}
