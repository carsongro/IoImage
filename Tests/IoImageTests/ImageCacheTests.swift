//
//  ImageCacheTests.swift
//  
//
//  Created by Carson Gross on 11/29/23.
//
//  Copyright (c) 2023 Carson Gross
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
            await cache.clearStorageCache()
            cache = nil
        }
    }
    
    func testClearCache() async throws {
        await cache.setEntry(.ready(testImage), forKey: testURL.absoluteString)
        await cache.clearMemoryCache()
        await cache.clearStorageCache()
        let entry = await cache.entry(forKey: testURL.absoluteString)
        XCTAssertNil(entry)
    }

    func testClearMemoryCache() async {
        await cache.setEntry(.ready(testImage), forKey: testURL.absoluteString)
        await cache.clearMemoryCache()
        let entry = await cache.entry(forKey: testURL.absoluteString)
        XCTAssertNotNil(entry)
    }
    
    func testClearStorageCache() async throws {
        await cache.setEntry(.ready(testImage), forKey: testURL.absoluteString)
        await cache.clearStorageCache()
        let entry = await cache.entry(forKey: testURL.absoluteString)
        XCTAssertNotNil(entry)
    }
    
    func testNoImage() async {
        let entry = await cache.entry(forKey: testURL.absoluteString)
        XCTAssertNil(entry)
    }
    
    
}
