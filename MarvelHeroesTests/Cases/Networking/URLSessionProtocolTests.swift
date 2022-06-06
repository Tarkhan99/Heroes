//
//  URLSessionProtocolTests.swift
//  MarvelHeroesTests
//
//  Created by Tarkhan Tahirov on 06.06.22.
//

import Quick
import Nimble
@testable import MarvelHeroes

class URLSessionProtocolTests: QuickSpec {
    
    override func spec() {
        
        var session: URLSession!
        var url: URL!
        
        beforeEach {
            url = URL(string: "https://example.com")!
            session = URLSession(configuration: .default)
        }
        
        afterEach {
            url = nil
            session = nil
        }
        
        describe("URLSessionTask") {
            
            it("conforms to URLSessionTaskProtocol") {
                let dataTask = session.dataTask(with: url)
                expect(dataTask).to(beAKindOf(URLSessionTaskProtocol.self))
            }
            
        }
        
        describe("URLSession") {
            
            it("conforms to URLSessionProtocol") {
                expect(session).to(beAKindOf(URLSessionProtocol.self))
            }
            
            it("makeDataTask creates task with expected URL") {
                let task = session.makeDataTask(with: url, completionHandler: { _, _, _ in}) as! URLSessionTask
                expect(task.originalRequest?.url).to(equal(url))
            }
            
        }
        
    }
    
}
