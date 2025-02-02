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
    }
    
    public init(
        url: URL,
        client: HTTPClient
    ) {
        self.URL = url
        self.client = client
    }

    public func load(completion: @escaping (Error) -> Void = { _ in }) {
        self.client.get(from: self.URL, completion: { error in
            completion(.connectivity)
        })
    }
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}
