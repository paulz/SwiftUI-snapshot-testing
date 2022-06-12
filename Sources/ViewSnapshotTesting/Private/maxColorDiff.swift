import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

extension CIImage {
    func removeTransparency() -> CIImage {
        addWhiteBackground().settingAlphaOne()
    }
    func addWhiteBackground() -> CIImage {
        let filter = CIFilter.sourceOverCompositing()
        filter.backgroundImage = .init(color: .white).cropped(to: extent)
        filter.inputImage = self
        return filter.outputImage!
    }
    func settingAlphaOne() -> CIImage {
        settingAlphaOne(in: extent)
    }
}

func diff(_ old: UIImage, _ new: UIImage) -> UIImage {
    let differenceFilter = diff(
        old.cgImage!,
        new.cgImage!
    )
    let difference = UIImage(ciImage: differenceFilter.outputImage!)
    return difference
}

func diff(_ old: Data, _ new: CGImage, size: CGSize) -> UIImage {
    diff(UIImage(data: old)!, UIImage(cgImage: new))
}

func diff(_ old: CGImage, _ new: CGImage) -> CICompositeOperation {
    diff(CIImage(cgImage: old), CIImage(cgImage: new))
}

func diff(_ old: CIImage, _ new: CIImage) -> CICompositeOperation {
    let differenceFilter: CICompositeOperation = CIFilter.differenceBlendMode()
    differenceFilter.inputImage = old.removeTransparency()
    differenceFilter.backgroundImage = new.removeTransparency()
    return differenceFilter
}

func histogramData(_ ciImage: CIImage) -> Data {
    let hist = CIFilter.areaHistogram()
    hist.inputImage = ciImage
    hist.extent = ciImage.extent
    return hist.value(forKey: "outputData") as! Data
}

func maxColorDiff(histogram: [UInt32]) -> Float {
    let rgb = stride(from: 0, to: histogram.count, by: 4).map { (index: Int)-> UInt32 in
        histogram[index] + histogram[index + 1] + histogram[index + 2]
    }
    if let last = rgb.lastIndex(where: { $0 > 0 }) {
        return Float(last) / Float(rgb.count)
    } else {
        return 1.0
    }
}

func histogram(ciImage: CIImage) -> [UInt32] {
    let data = histogramData(ciImage)
    let count = data.count / MemoryLayout<UInt32>.stride
    let result: [UInt32] = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
        let pointer = bytes.bindMemory(to: UInt32.self)
        return Array(UnsafeBufferPointer(start: pointer.baseAddress, count: count))
    }
    return result
}

func compare(_ left: UIImage, _ right: UIImage) -> ImageComparisonResult {
    let image1 = CIImage(image: left)!.premultiplyingAlpha()
    let image2 = CIImage(image: right)!.premultiplyingAlpha()
    let diffOperation = diff(image1, image2)
    return ImageComparisonResult(difference: diffOperation.outputImage!)
}

let workColorSpace = CGColorSpace(name: CGColorSpace.displayP3)!
//let workColorSpace = CGColorSpace(name: CGColorSpace.extendedSRGB)!
//let workColorSpace = CGColorSpace(name: CGColorSpace.extendedDisplayP3)!

func compare(_ left: Data, _ right: Data) -> ImageComparisonResult {
    let options: [CIImageOption : Any] = [
        .colorSpace: workColorSpace,
        .nearestSampling: NSNumber(booleanLiteral: true)
    ]
    let image1 = CIImage(data: left, options: options)!
        .premultiplyingAlpha()
    let image2 = CIImage(data: right, options: options)!
        .premultiplyingAlpha()
    let diffOperation = diff(image1, image2)
    return ImageComparisonResult(difference: diffOperation.outputImage!)
}

struct ImageComparisonResult {
    let difference: CIImage
    
    func maxColorDifference() -> Float {
        maxColorDiff(histogram: histogram(ciImage: difference))
    }
}
