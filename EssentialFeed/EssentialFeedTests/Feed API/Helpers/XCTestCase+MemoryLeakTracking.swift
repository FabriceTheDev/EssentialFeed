//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Fabrice M. on 18/07/2025.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
