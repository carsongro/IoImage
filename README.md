# IoImage

IoImage is a library for downloading, caching, and displays images from the web in SwiftUI with behavior similar to AsyncImage.

## Example

```swift
import IoImage

struct ImageView: View {
    var body: some View {
        IoImageView(url: URL(string: ""))
            .resizable()
            .placeholder {
                Image(systemName: "person.circle.fill")
                    .resizable()
            }
    }
}
```

It can also be used to fetch a SwiftUI Image

```swift
    let image = try await IoImageLoader.shared.Image(from: URL(string: ""))
```

## Installation

Install this using the Swift Package Manager
