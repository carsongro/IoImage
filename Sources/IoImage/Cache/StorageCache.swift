//
//  StorageCache.swift
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

public actor StorageCache {
    
    private var documentsDirectory: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] }
    
    private let expiration = FileExpiration.days(7)
    
    private let sizeLimit: UInt = 1_000_000_000 // 1GB
    
    public func item(forKey key: String) -> UIImage? {
        let filename = documentsDirectory.appendingPathComponent(key)
        
        guard FileManager.default.fileExists(atPath: filename.path()) else { return nil }
        
        do {
            let data = try Data(contentsOf: filename)
            extendItemExpiration(filename: filename)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    public func setItem(_ image: UIImage, forKey key: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let filename = documentsDirectory.appendingPathComponent(key)
        try? data.write(to: filename)
        do {
            try FileManager.default.setAttributes(
                [
                    .creationDate: Date().attributeDate,
                    .modificationDate: expiration.estimatedExpirationSinceNow.attributeDate
                ],
                ofItemAtPath: filename.path()
            )
        } catch {
            try? FileManager.default.removeItem(at: filename)
        }
    }
    
    public func removeItem(forKey key: String) {
        let filename = documentsDirectory.appendingPathComponent(key)
        try? FileManager.default.removeItem(at: filename)
    }
    
    public func allItemsSize() throws -> UInt {
        allItemURLs(urlResourceKeys: [.fileSizeKey]).reduce(0) { size, url in
            do {
                let values = try url.resourceValues(forKeys: Set([.fileSizeKey]))
                return size + UInt(values.fileSize ?? 0)
            } catch {
                return size
            }
        }
    }
    
    public func removeExpiredItems() {
        let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .contentModificationDateKey]
        let urls = allItemURLs(urlResourceKeys: resourceKeys)
        let expiredItems = urls.filter { url in
            do {
                let values = try url.resourceValues(forKeys: Set(resourceKeys))
                if values.isDirectory ?? false {
                    return false
                }
                guard let modificationDate = values.contentModificationDate else {
                    return true
                }
                
                return modificationDate.isPastNow()
            } catch {
                return true
            }
        }
        
        for url in expiredItems {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    public func removeItemsOverSizeLimit() {
        guard var totalSize = try? allItemsSize(), totalSize >= sizeLimit else { return }
        
        let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .creationDateKey, .fileSizeKey]
        
        var files = allItemURLs(urlResourceKeys: resourceKeys).sorted { file1, file2 in
            let date1 = (try? file1.resourceValues(forKeys: Set(resourceKeys)).creationDate) ?? .distantPast
            let date2 = (try? file2.resourceValues(forKeys: Set(resourceKeys)).creationDate) ?? .distantPast
            return date1 > date2
        }
        
        while totalSize > sizeLimit / 2, let file = files.popLast() {
            let value = try? file.resourceValues(forKeys: Set(resourceKeys))
            totalSize -= UInt(value?.fileSize ?? 0)
            try? FileManager.default.removeItem(at: file)
        }
    }
    
    private func allItemURLs(urlResourceKeys: [URLResourceKey]) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: documentsDirectory,
            includingPropertiesForKeys: urlResourceKeys,
            options: .skipsHiddenFiles
        ) else { return [] }
        return enumerator.compactMap { $0 as? URL }
    }
    
    private func extendItemExpiration(filename: URL) {
        try? FileManager.default.setAttributes(
            [
                .creationDate: Date().attributeDate,
                .modificationDate: expiration.estimatedExpirationSinceNow.attributeDate
            ],
            ofItemAtPath: filename.path()
        )
    }
}

extension StorageCache {
    
    private enum TimeConstants {
        static let secondsInDay = 86_400
    }
    
    private enum FileExpiration {
        case days(Int)
        
        func estimatedExpirationSince(_ date: Date) -> Date {
            switch self {
            case .days(let days):
                let duration: TimeInterval = TimeInterval(TimeConstants.secondsInDay) * TimeInterval(days)
                return date.addingTimeInterval(duration)
            }
        }
        
        var estimatedExpirationSinceNow: Date {
            return estimatedExpirationSince(Date.now)
        }
    }
}

extension Date {
    func isPastNow() -> Bool {
        return timeIntervalSince(Date.now) <= 0
    }
    
    var attributeDate: Date {
        return Date(timeIntervalSince1970: ceil(timeIntervalSince1970))
    }
}
