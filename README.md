# IoImage

IoImage is a library for downloading, caching, and displays images from the web in SwiftUI with behavior similar to AsyncImage.

## Example

```swift
import IoImage

struct ImageView: View {
    var body: some View {
        IoImage(url: URL(string: ""))
            .resizable()
            .placeholder {
                Image(systemName: "person.circle.fill")
            }
    }
}
```

## Installation

Install this using the Swift Package Manager
