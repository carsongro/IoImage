// MIT License
//
// Copyright (c) 2023 Carson Gross
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI

/// An global actor for loading images
@globalActor
actor IoImageLoader {
    public static let shared = IoImageLoader()
    
    private init() {}
    
    final class CacheEntry {
        enum CacheEntryType {
            case ready(Image)
            case inProgress(Task<Image, Error>)
        }
        
        var cacheEntryType: CacheEntryType?
    }
    
    private let cache = NSCache<NSString, CacheEntry>()
    
    private enum ImageError: Error {
        case dataError
    }
    
    /// Returns an image from a URL
    /// - Parameter url: The URL of the image
    /// - Returns: A SwiftUI `Image` from the URL
    func Image(
        from url: URL
    ) async throws -> Image {
        let key = url.absoluteString as NSString
        
        if let entry = cache.object(forKey: key),
           let status = entry.cacheEntryType {
            switch status {
            case .ready(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }
        
        let task = Task {
            try await downloadImage(url: url)
        }
        
        let cacheEntry = CacheEntry()
        cacheEntry.cacheEntryType = .inProgress(task)
        
        cache.setObject(cacheEntry, forKey: key)
        
        do {
            let image = try await task.value
            cacheEntry.cacheEntryType = .ready(image)
            cache.setObject(cacheEntry, forKey: key)
            return image
        } catch {
            cache.removeObject(forKey: key)
            throw error
        }
    }
    
    /// Downloads an image from a URL
    /// - Parameter url: The url of the image
    /// - Returns: A SwiftUI `Image`
    private func downloadImage(
        url: URL
    ) async throws -> Image {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let uiImage = UIImage(data: data) else { throw ImageError.dataError }
        return SwiftUI.Image(uiImage: uiImage)
    }
}
