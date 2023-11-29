//
//  IoImageCache.swift
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

import SwiftUI

// TODO: when app enters background clear disk storage

public enum CacheEntry {
    case ready(UIImage)
    case inProgress(Task<UIImage, Error>)
}

public actor IoImageCache {
    
    private let memoryCache = MemoryCache()
    
    public func entry(forKey key: String) async -> CacheEntry? {
        if let entry = await memoryCache.entry(forKey: key) {
            return entry
        } else {
            return nil
        }
    }
    
    public func setEntry(_ entry: CacheEntry, forKey key: String) async {
        await memoryCache.setEntry(entry, forKey: key)
    }
    
    public func removeEntry(forKey key: String) async {
        await memoryCache.removeEntry(forKey: key)
    }
}

