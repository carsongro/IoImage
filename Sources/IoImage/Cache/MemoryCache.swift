//
//  MemoryCache.swift
//
//
//  Created by Carson Gross on 11/28/23.
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

import Foundation

public actor MemoryCache {
    private let cache = NSCache<NSString, CacheEntryObject>()
    
    public func entry(forKey key: String) -> CacheEntry? {
        if let entry = cache.object(forKey: key as NSString)?.entry {
            return entry
        } else {
            return nil
        }
    }
    
    public func setEntry(_ entry: CacheEntry, forKey key: String) {
        cache.setObject(CacheEntryObject(entry), forKey: key as NSString)
    }
    
    public func removeEntry(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
}

extension MemoryCache {
    final class CacheEntryObject {
        let entry: CacheEntry
        
        init(_ entry: CacheEntry) {
            self.entry = entry
        }
    }
}
