//
//  MockMarvelNetworkClient.swift
//  MarvelHeroesTests
//
//  Created by Tarkhan Tahirov on 06.06.22.
//

import Foundation
@testable import MarvelHeroes

class MockMarvelNetworkClient: CharactersService {
    
    var isFetchCharactersCalled = false
    
    var completionResponse: CharactersResponse?
    var completionClosure: ((CharactersResponse?, Error?) -> ())?
    
    func fetchCharacters(query: String?, page: Int, completion: @escaping (CharactersResponse?, Error?) -> ()) -> URLSessionTaskProtocol? {
        isFetchCharactersCalled = true
        completionClosure = completion
        return nil
    }
    
    func fetchSuccess() {
        completionClosure?(completionResponse, nil)
    }
    
    func fetchFail(error: Error) {
        completionClosure?(nil, error)
    }
    
}
