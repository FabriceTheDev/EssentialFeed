//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Fabrice M. on 02/02/2025.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public final class RemoteFeedLoader {
    private let URL: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(
        url: URL,
        client: HTTPClient
    ) {
        self.URL = url
        self.client = client
    }

    public func load(completion: @escaping (Result) -> Void) {
        self.client.get(from: self.URL, completion: { result in
            switch result {
            case let .success(data, _):
                if let _ = try? JSONSerialization.jsonObject(with: data) {
                    completion(.success([]))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        })
    }
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
