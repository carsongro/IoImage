//
//  ImageCacheTests.swift
//  
//
//  Created by Carson Gross on 11/29/23.
//

import XCTest
@testable import IoImage

final class ImageCacheTests: XCTestCase {
    
    var cache: IoImageCache!

    override func setUp() {
        super.setUp()
        cache = IoImageCache()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        Task {
            await cache.clearMemoryCache()
            try await cache.clearStorageCache()
            cache = nil
        }
    }

    func testClearMemoryCache() async {
        await cache.setEntry(.ready(UIImage(systemName: "person")!), forKey: testURL.absoluteString)
        await cache.clearMemoryCache()
        let entry = await cache.entry(forKey: testURL.absoluteString)
        XCTAssertNotNil(entry)
    }
}
