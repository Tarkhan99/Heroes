//
//  MarvelImageClientTests.swift
//  MarvelHeroesTests
//
//  Created by Tarkhan Tahirov on 06.06.22.
//

import Quick
import Nimble
@testable import MarvelHeroes

class MarvelImageClientTests: QuickSpec {
    
    override func spec() {
        
        var sut: MarvelImageClient!
        var mockSession: MockURLSession!
        var url: URL!
        
        beforeEach {
            url = URL(string: "https://example.com/image")!
            mockSession = MockURLSession()
            sut = MarvelImageClient(session: mockSession, responseQueue: nil)
        }
        
        afterEach {
            url = nil
            mockSession = nil
            sut = nil
        }
        
        
        describe("image client") {
            
            it("conforms to ImageService") {
                expect(sut as AnyObject).to(beAKindOf(ImageService.self))
            }
            
            context("when initialized") {
                
                it("sets session") {
                    expect(sut.session === mockSession).to(beTrue())
                }
                
                it("sets response queue") {
                    let responseQueue = DispatchQueue.main
                    
                    sut = MarvelImageClient(session: mockSession, responseQueue: responseQueue)
                    
                    expect(sut.responseQueue).to(equal(responseQueue))
                }
                
                it("creates empty cache for images") {
                    expect(sut.imageCacheForURL.isEmpty).to(beTrue())
                }
                
                it("creates empty cache for data tasks") {
                    expect(sut.taskCacheForImageView.isEmpty).to(beTrue())
                }
                
            }
            
            context("load image") {
                
                var receivedImage: UIImage?
                var receivedError: Error?
                var dataTask: MockURLSessionTask?
                var expectedImage: UIImage!
                
                beforeEach {
                    expectedImage = UIImage(named: "image")!
                    dataTask = sut.loadImage(fromURL: url) { image, error in
                        receivedImage = image
                        receivedError = error
                    } as? MockURLSessionTask
                }
                
                afterEach {
                    expectedImage = nil
                    receivedError = nil
                    receivedImage = nil
                    dataTask = nil
                }
                
                it("create task with expected url") {
                    expect(dataTask?.url).to(equal(url))
                }
                
                it("calls resume for task") {
                    expect(dataTask?.calledResume).to(beTrue())
                }
                
                it("for given image data calls completion with image") {
                    dataTask?.completionHandler(expectedImage.pngData(), nil, nil)
                    
                    expect(receivedImage?.pngData()).to(equal(expectedImage.pngData()))
                }
                
                it("for given error calls completion with error") {
                    let expectedError = NSError(domain: "com.marvel", code: 34)
                    
                    dataTask?.completionHandler(nil, nil, expectedError)
                    
                    let actualError = receivedError as? NSError
                    expect(actualError?.domain).to(equal(expectedError.domain))
                    expect(actualError?.code).to(equal(expectedError.code))
                }
                
                it("for given image caches image") {
                    dataTask?.completionHandler(expectedImage.pngData(), nil, nil)
                    
                    expect(sut.imageCacheForURL[url]?.pngData()).to(equal(expectedImage.pngData()))
                }
                
                it("for cached image sets data task to nil") {
                    dataTask?.completionHandler(expectedImage.pngData(), nil, nil)
                    
                    dataTask = sut.loadImage(fromURL: url, completion: { _, _ in }) as? MockURLSessionTask
                    
                    expect(dataTask).to(beNil())
                }
                
                it("for cached image sets call comletion with image") {
                    dataTask?.completionHandler(expectedImage.pngData(), nil, nil)
                    receivedImage = nil
                    
                    dataTask = sut.loadImage(fromURL: url, completion: { image, error in
                        receivedImage = image
                    }) as? MockURLSessionTask
                    
                    expect(receivedImage?.pngData()).to(equal(expectedImage.pngData()))
                }
                
            }
            
            context("load image dispatches result to response queue") {
                
                var receivedThread: Thread?
                var dataTask: MockURLSessionTask?
                
                beforeEach {
                    mockSession.givenDispatchQueue()
                    sut = MarvelImageClient(session: mockSession, responseQueue: .main)
                    
                    dataTask = sut.loadImage(fromURL: url) { image, error in
                        receivedThread = Thread.current
                    } as? MockURLSessionTask
                }
                
                afterEach {
                    receivedThread = nil
                    dataTask = nil
                }
                
                it("for given error") {
                    dataTask?.completionHandler(nil, nil, NSError(domain: "com.marvel", code: 34))
                    
                    expect(receivedThread?.isMainThread).toEventually(beTrue(), timeout: .milliseconds(500))
                }
                
                it("for given image result") {
                    dataTask?.completionHandler(UIImage(named: "image")?.pngData(), nil, nil)
                    
                    expect(receivedThread?.isMainThread).toEventually(beTrue(), timeout: .milliseconds(500))
                }
                
            }
            
            
            context("set image to imageview") {
                
                var imageView: UIImageView!
                
                beforeEach {
                    imageView = UIImageView()
                }
                
                afterEach {
                    imageView = nil
                }
                
                it("cancels existing task") {
                    let task = MockURLSessionTask(url: url, completionHandler: { _, _, _ in }, queue: nil)
                    sut.taskCacheForImageView[imageView] = task
                    
                    sut.setImage(fromURL: url, imageView: imageView)
                    
                    expect(task.calledCancel).to(beTrue())
                }
                
                it("caches task") {
                    sut.setImage(fromURL: url, imageView: imageView)
                    
                    let receivedTask = sut.taskCacheForImageView[imageView] as? MockURLSessionTask
                    
                    expect(receivedTask?.url).to(equal(url))
                }
                
                context("after load image result") {
                    
                    var expectedImage: UIImage!
                    var receivedTask: MockURLSessionTask?
                    
                    beforeEach {
                        expectedImage = UIImage(named: "image")
                        sut.setImage(fromURL: url, imageView: imageView)
                        receivedTask = sut.taskCacheForImageView[imageView] as? MockURLSessionTask
                        receivedTask?.completionHandler(expectedImage.pngData(), nil, nil)
                    }
                    
                    afterEach {
                        expectedImage = nil
                        receivedTask = nil
                    }
                    
                    it("removes cached task") {
                        expect(sut.taskCacheForImageView[imageView]).to(beNil())
                    }
                    
                    it("sets image on completion") {
                        expect(imageView.image?.pngData()).to(equal(expectedImage.pngData()))
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
}
