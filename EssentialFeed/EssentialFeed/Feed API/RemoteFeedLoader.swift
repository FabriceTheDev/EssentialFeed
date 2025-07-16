//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Fabrice M. on 02/02/2025.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let URL: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult<Error>
    
    public init(
        url: URL,
        client: HTTPClient
    ) {
        self.URL = url
        self.client = client
    }

    public func load(completion: @escaping (Result) -> Void) {
        self.client.get(from: self.URL, completion: { [weak self] result in
            guard self != nil else { return }

            switch result {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        })
    }
}
