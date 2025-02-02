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
    
    public init(
        url: URL,
        client: HTTPClient
    ) {
        self.URL = url
        self.client = client
    }

    public func load() {
        self.client.get(from: self.URL)
    }
}

public protocol HTTPClient {
    func get(from url: URL)
}
