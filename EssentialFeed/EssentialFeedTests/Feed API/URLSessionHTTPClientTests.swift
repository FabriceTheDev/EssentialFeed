//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Fabrice M. on 17/07/2025.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        self.session.dataTask(with: url) { _, _, _ in
            
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)

        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)

        let sut = URLSessionHTTPClient(session: session)

        sut.get(from: url)

        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    // MARK: - Helpers
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        private var stubs = [URL: URLSessionDataTask]()
        
        func stub(url: URL, task: URLSessionDataTask) {
            self.stubs[url] = task
        }
        
        override func dataTask(with url : URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            self.receivedURLs.append(url)
            return self.stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            self.resumeCallCount += 1
        }
    }
}
