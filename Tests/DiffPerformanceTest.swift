import XCTest

/**
 Compare performance of image comparison
 using CoreImage vs vImage frameworks

 on iMacPro
 for preloaded images
 performance of CoreImage is 4 times faster (0.0015753 vs 0.0060786)

 including image load
 performance of CoreImage is 1.5 times slower (0.018587 vs 0.011776)
 
 on Macbook Pro
 3.5 faster (0.0021594 vs 0.0073569)
 with load 1.7 times slower (0.024396 vs 0.014482)
 */

import CoreImage
import CoreImage.CIFilterBuiltins
@testable import ViewSnapshotTesting

class DiffPerformanceTest: XCTestCase {
    let bundle = Bundle(for: DiffPerformanceTest.self)
    var image1Url: URL!
    var image2Url: URL!

    override func setUpWithError() throws {
        image1Url = folderUrl().appendingPathComponent("AvatarView-1.png")
        image2Url = folderUrl().appendingPathComponent("AvatarView-2.png")
    }

    func test_CoreImage_AndLoad_Performance() throws {
        measure {
            let image1 = CIImage(contentsOf: image1Url)!
            let image2 = CIImage(contentsOf: image2Url)!
            let diffOperation = diff(image1, image2)
            let diffOutput = diffOperation.outputImage!
            _ = maxColorDiff(histogram: histogram(ciImage: diffOutput))
        }
    }

    func test_CoreImage_Performance() throws {
        let image1 = CIImage(contentsOf: image1Url)!
        let image2 = CIImage(contentsOf: image2Url)!
        let diffOperation = diff(image1, image2)
        let diffOutput = diffOperation.outputImage!
        let diff = maxColorDiff(histogram: histogram(ciImage: diffOutput))
        XCTAssertEqual(0.015625, diff)

        measure {
            _ = maxColorDiff(histogram: histogram(ciImage: diffOutput))
        }
    }
}
