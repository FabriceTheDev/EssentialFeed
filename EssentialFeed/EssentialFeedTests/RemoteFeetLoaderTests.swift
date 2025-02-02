//
//  RemoteFeetLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Fabrice M. on 02/02/2025.
//

import XCTest
import EssentialFeed

final class RemoteFeetLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = self.makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "www.google.com")!
        let (sut, client) = self.makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "www.google.com")!
        let (sut, client) = self.makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    // Helpers
    
    private func makeSUT(
        url: URL = URL(string: "www.google.com")!
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        
        func get(from url: URL) {
            self.requestedURLs.append(url)
        }
    }
}
