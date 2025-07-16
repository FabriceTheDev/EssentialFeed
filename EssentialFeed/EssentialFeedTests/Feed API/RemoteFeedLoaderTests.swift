//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Fabrice M. on 02/02/2025.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = self.makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "www.google.com")!
        let (sut, client) = self.makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "www.google.com")!
        let (sut, client) = self.makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = self.makeSUT()
        
        self.expect(sut, toCompleteWith: self.failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = self.makeSUT()

        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            self.expect(sut, toCompleteWith: self.failure(.invalidData)) {
                let json = self.makeItemJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = self.makeSUT()
        
        self.expect(sut, toCompleteWith: self.failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = self.makeSUT()
        
        self.expect(sut, toCompleteWith: .success([])) {
            let emptyJSONList = self.makeItemJSON([])
            client.complete(withStatusCode: 200, data: emptyJSONList)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = self.makeSUT()
        
        let item1 = self.makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!
        )
        
        let item2 = self.makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!
        )
        
        let items = [item1.model, item2.model]
        
        self.expect(sut, toCompleteWith: .success(items)) {
            let json = self.makeItemJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_load_doesNotDeliverTesultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: self.makeItemJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // Helpers
    
    private func makeSUT(
        url: URL = URL(string: "www.google.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        self.trackForMemoryLeaks(sut, file: file, line: line)
        self.trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any])  {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString
        ].reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value { acc[e.key] = value }
        }
        
        return (item, json)
    }
    
    private func makeItemJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = [
            "items": items
        ]
        return try!  JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith expectedResult: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResults in
            switch (receivedResults, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResults) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }

    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        var requestedURLs: [URL] {
            return self.messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            self.messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            self.messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: self.requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!

            self.messages[index].completion(.success(data, response))
        }
    }
}
