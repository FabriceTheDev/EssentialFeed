//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Fabrice M. on 02/02/2025.
//

import Foundation

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
            case let .success(data, response):
                do {
                    let items = try FeedItemsMapper.map(data, response)
                    return completion(.success(items))
                } catch {
                    return completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        })
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, response)
            return .success(items)
        } catch {
            return .failure(.invalidData)
        }
    }
}
