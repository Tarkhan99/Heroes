//
//  MarvelNetworkClientTests.swift
//  MarvelHeroesTests
//
//  Created by Tarkhan Tahirov on 06.06.22.
//

import Quick
import Nimble
@testable import MarvelHeroes
import Foundation

class MarvelNetworkClientTests: QuickSpec {
    
    override func spec() {
        
        var sut: MarvelNetworkClient!
        var baseURL: URL!
        var mockSession: MockURLSession!
        var publicKey: String!
        var privateKey: String!
        
        var charactersURL: URL {
            return URL(string: "v1/public/characters", relativeTo: baseURL)!
        }
        
        beforeEach {
            privateKey = "privateKey"
            publicKey = "publicKey"
            mockSession = MockURLSession()
            baseURL = URL(string: "https://example.com/")!
            sut = MarvelNetworkClient(
                baseURL: baseURL,
                session: mockSession,
                responseQueue: nil,
                publicKey: publicKey,
                privateKey: privateKey
            )
        }
        
        afterEach {
            privateKey = nil
            publicKey = nil
            mockSession = nil
            baseURL = nil
            sut = nil
        }
        
        describe("MarvelNetworkClient") {
            
            it("conforms to CharactersService") {
                expect(sut).to(beAKindOf(CharactersService.self))
            }
            
            context("when initialized") {
                
                it("sets baseURL") {
                    expect(sut.baseURL).to(equal(baseURL))
                }
                
                it("sets session") {
                    expect(sut.session === mockSession).to(beTrue())
                }
                
                it("sets response queue") {
                    let responseQueue = DispatchQueue.main
                    
                    sut = MarvelNetworkClient(baseURL: baseURL,
                                              session: mockSession,
                                              responseQueue: responseQueue,
                                              publicKey: publicKey,
                                              privateKey: privateKey)
                    
                    expect(sut.responseQueue).to(equal(responseQueue))
                }
                
                it("sets publicKey") {
                    expect(sut.publicKey).to(equal(publicKey))
                }
                
                it("sets privateKey") {
                    expect(sut.privateKey).to(equal(privateKey))
                }
                
            }
            
            context("fetch characters") {
                
                var dataTask: MockURLSessionTask!
                
                beforeEach {
                    dataTask = sut.fetchCharacters(query: "query", page: 2, completion: { _, _ in }) as? MockURLSessionTask
                }
                
                it("calls expected URL") {
                    expect(dataTask.url.absoluteStringByTrimmingQuery()).to(equal(charactersURL.absoluteString))
                }
                
                it("sets query items") {
                    let urlComponents = URLComponents(string: dataTask.url.absoluteString)
                    let queryItems = urlComponents?.queryItems ?? []
                    
                    expect(queryItems.first(where: { $0.name == "nameStartsWith" })?.value).to(equal("query"))
                    expect(queryItems.first(where: { $0.name == "apikey" })?.value).to(equal(publicKey))
                    expect(queryItems.first(where: { $0.name == "offset" })?.value).to(equal("\(sut.limit*2)"))
                }
                
                it("calls resume task") {
                    expect(dataTask.calledResume).to(beTrue())
                }
                
            }
            
            context("for fetch characters data task result") {
                
                var calledCompletion = false
                var receivedCharacters: CharactersResponse? = nil
                var receivedError: Error? = nil
                var mockTask: MockURLSessionTask?
                
                beforeEach {
                    mockTask = sut.fetchCharacters(query: nil, page: 0, completion: { response, error in
                        calledCompletion = true
                        receivedCharacters = response
                        receivedError = error
                    }) as? MockURLSessionTask
                }
                
                afterEach {
                    calledCompletion = false
                    receivedCharacters = nil
                    receivedError = nil
                    mockTask = nil
                }
                
                
                it("if status code is 500 calls completion") {
                    let response = HTTPURLResponse(url: charactersURL, statusCode: 500, httpVersion: nil, headerFields: nil)
                    mockTask?.completionHandler(nil, response, nil)
                    
                    expect(calledCompletion).to(beTrue())
                    expect(receivedCharacters).to(beNil())
                    expect(receivedError).to(beNil())
                }
                
                it("if has error calls completion with error") {
                    let expectedError = NSError(domain: "com.marvel", code: 11)
                    let response = HTTPURLResponse(url: charactersURL, statusCode: 200, httpVersion: nil, headerFields: nil)
                    mockTask?.completionHandler(nil, response, expectedError)
                    
                    expect(calledCompletion).to(beTrue())
                    expect(receivedCharacters).to(beNil())
                    
                    expect(receivedError as? NSError).to(equal(expectedError))
                }
                
                it("if has valid json response calls completion CharacterResponse") {
                    let data = try! Data.fromJSON(fileName: "CharactersListResponse")
                    let expectedResponse = try! JSONDecoder().decode(CharactersResponse.self, from: data)
                    
                    let response = HTTPURLResponse(url: charactersURL, statusCode: 200, httpVersion: nil, headerFields: nil)
                    mockTask?.completionHandler(data, response, nil)
                                        
                    expect(calledCompletion).to(beTrue())
                    expect(receivedError).to(beNil())
                    expect(receivedCharacters).to(equal(expectedResponse))
                }
                
                it("if has invalid json response calls completion CharacterResponse") {
                    let data = try! Data.fromJSON(fileName: "InvalidResponse")
                    var expectedError: NSError!
                    do {
                        _ = try JSONDecoder().decode(CharactersResponse.self, from: data)
                    }catch {
                        expectedError = error as NSError
                    }
                    
                    let response = HTTPURLResponse(url: charactersURL, statusCode: 200, httpVersion: nil, headerFields: nil)
                    mockTask?.completionHandler(nil, response, expectedError)
                                        
                    expect(calledCompletion).to(beTrue())
                    expect(receivedCharacters).to(beNil())
                    
                    let actualError = receivedError as? NSError
                    expect(actualError?.domain).to(equal(expectedError.domain))
                    expect(actualError?.code).to(equal(expectedError.code))
                }
            }
            
            context("fetch characters dispatches to main queue") {
                
                var thread: Thread?
                var mockTask: MockURLSessionTask?
                
                beforeEach {
                    mockSession.givenDispatchQueue()
                    
                    sut = MarvelNetworkClient(
                        baseURL: baseURL,
                        session: mockSession,
                        responseQueue: .main,
                        publicKey: publicKey,
                        privateKey: privateKey
                    )
                    
                    mockTask = sut.fetchCharacters(query: nil, page: 0, completion: { respone, error in
                        thread = Thread.current
                    }) as? MockURLSessionTask
                    
                    
                }
                
                afterEach {
                    sut = nil
                    mockTask = nil
                    thread = nil
                }
                
                it("if has status error") {
                    let response = HTTPURLResponse(url: charactersURL, statusCode: 500, httpVersion: nil, headerFields: nil)
                    mockTask?.completionHandler(nil, response, nil)
                    
                    expect(thread?.isMainThread).toEventually(beTrue(), timeout: .milliseconds(500))
                }
                
                it("for given error") {
                    let error = NSError(domain: "com.marvel", code: 11)
                    let response = HTTPURLResponse(url: charactersURL, statusCode: 200, httpVersion: nil, headerFields: nil)

                    mockTask?.completionHandler(nil, response, error)

                    expect(thread?.isMainThread).toEventually(beTrue(), timeout: .milliseconds(500))
                }
                
                it("for valid response") {
                    let data = try! Data.fromJSON(fileName: "CharactersListResponse")
                    let response = HTTPURLResponse(url: charactersURL, statusCode: 200, httpVersion: nil, headerFields: nil)

                    mockTask?.completionHandler(data, response, nil)

                    expect(thread?.isMainThread).toEventually(beTrue(), timeout: .milliseconds(500))
                }

                it("for invalid response") {
                    let data = try! Data.fromJSON(fileName: "InvalidResponse")
                    let response = HTTPURLResponse(url: charactersURL, statusCode: 200, httpVersion: nil, headerFields: nil)
                    
                    mockTask?.completionHandler(data, response, nil)
                    
                    expect(thread?.isMainThread).toEventually(beTrue(), timeout: .milliseconds(500))
                }
            
            }
            
            
        }
        
    }
    
    
}


extension URL {
    func absoluteStringByTrimmingQuery() -> String? {
        if var urlcomponents = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            urlcomponents.query = nil
            return urlcomponents.string
        }
        return nil
    }
}
