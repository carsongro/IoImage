import XCTest
@testable import IoImage

let testURL = URL(string: "https://github.com/carsongro/IoImage/blob/main/Tests/IoImageTests/clouds.jpeg?raw=true")!

final class ImageLoaderTests: XCTestCase {
    func testDownloadImage() {
        Task {
            do {
                let image = try await IoImageLoader.shared.Image(from: testURL)
                XCTAssertNotNil(image)
            } catch {
                XCTAssertTrue(false)
            }
        }
    }
}
