# IoImage

IoImage is a library for downloading, caching to memory and disk, and displaying images in SwiftUI from the web with support for resizable and placeholders.

## Example

IoImageView can be used in SwiftUI to display an image from a url.

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

When using IoImageView or IoImageLoader, the images are automatically cached on memory and disk. IoImageLoader can be used to fetch a SwiftUI Image or a UIImage from a url.

```swift
let image = try await IoImageLoader.shared.Image(from: URL(string: ""))

let uiImage = try await IoImageLoader.shared.loadImage(from: URL(string: ""))
```

## Installation

Install this using the Swift Package Manager

### License
IoImage is released under the MIT License. See LICENSE for details.
