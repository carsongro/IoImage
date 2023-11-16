
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
    
    func Image(from url: URL) async throws -> Image {
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
    
    private func downloadImage(url: URL) async throws -> Image {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let uiImage = UIImage(data: data) else { throw ImageError.dataError }
        return SwiftUI.Image(uiImage: uiImage)
    }
}
