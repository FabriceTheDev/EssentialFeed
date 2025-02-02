//
//  RemoteFeetLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Fabrice M. on 02/02/2025.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let URL: URL
    
    init(
        url: URL,
        client: HTTPClient
    ) {
        self.URL = url
        self.client = client
    }
    func load() {
        self.client.get(from: self.URL)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        self.requestedURL = url
    }
}

final class RemoteFeetLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "www.google.com")!
        let client = HTTPClientSpy()
        let _ = RemoteFeedLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_init_doesRequestDataFromURL() {
        let url = URL(string: "www.google.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }

}
