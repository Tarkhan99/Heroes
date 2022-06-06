//
//  CharactersViewModel.swift
//  MarvelHeroes
//
//  Created by Tarkhan Tahirov on 05.06.22.
//

import Foundation

protocol CharactersListViewModelType {
    
    var charactersResponse: CharactersResponse? { get }
    var cellViewModels: [CharacterCellViewModelType] { get }
    var errorMessage: String? { get }
    var isLoading: Bool { get }
    
    var page: Int { get set }
    var searchQuery: String? { get set }
    
    var reloadCollectionView: (() ->  ())? { get set }
    var showErrorAlertMessage: (() -> ())? { get set }
    var updateLoadingStatus: (() -> ())? { get set }
    
    func fetchCharacters()
    func loadMoreCharacters()
}

class CharactersListViewModel: CharactersListViewModelType {
    
    var charactersResponse: CharactersResponse?
    
    var cellViewModels: [CharacterCellViewModelType] = [] {
        didSet {
            reloadCollectionView?()
        }
    }
    
    var errorMessage: String? {
        didSet {
            showErrorAlertMessage?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            updateLoadingStatus?()
        }
    }
    
    var page: Int = 0
    var searchQuery: String?
    
    var reloadCollectionView: (() -> ())?
    var showErrorAlertMessage: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    
    var charactersService: CharactersService
    var dataTask: URLSessionTaskProtocol?
    
    init(with charactersService: CharactersService) {
        self.charactersService = charactersService
    }
    
    func fetchCharacters() {
        isLoading = true
        page = 0
        dataTask = charactersService.fetchCharacters(query: searchQuery, page: page) { [weak self] response, error in
            self?.isLoading = false
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                self?.charactersResponse = response
                if let characters = response?.data?.results {
                    self?.cellViewModels = characters.map { CharacterCellViewModel(character: $0) }
                }
            }
        }
    }
    
    func loadMoreCharacters() {
        guard let offset = charactersResponse?.data?.offset,
              let total = charactersResponse?.data?.total,
              offset < total
        else { return }
        
        page += 1
        dataTask = charactersService.fetchCharacters(query: searchQuery, page: page) { [weak self] response, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                if let characters = response?.data?.results {
                    self?.charactersResponse?.data?.offset = response?.data?.offset
                    self?.charactersResponse?.data?.results?.append(contentsOf: characters)
                    self?.cellViewModels.append(contentsOf: characters.map { CharacterCellViewModel(character: $0) })
                }
            }
        }
        
    }
    
}
