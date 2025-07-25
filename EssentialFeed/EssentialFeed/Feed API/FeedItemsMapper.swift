//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Fabrice M. on 15/07/2025.
//

import Foundation

internal final class FeedItemsMapper {

    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedItem] {
            return items.map{ $0.item }
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(
                id: self.id,
                description: self.description,
                location: self.location,
                imageURL: self.image
            )
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == self.OK_200,
                let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        return .success(root.feed)
    }
}
