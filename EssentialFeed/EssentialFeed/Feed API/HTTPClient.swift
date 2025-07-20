//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Fabrice M. on 15/07/2025.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
