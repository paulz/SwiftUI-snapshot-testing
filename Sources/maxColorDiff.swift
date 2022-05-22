import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

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

public func diff(_ old: CIImage, _ new: CIImage) -> CICompositeOperation {
    let differenceFilter: CICompositeOperation = CIFilter.differenceBlendMode()
    differenceFilter.inputImage = old
    differenceFilter.backgroundImage = new
    return differenceFilter
}

func histogramData(_ ciImage: CIImage) -> Data {
    let hist = CIFilter.areaHistogram()
    hist.inputImage = ciImage
    hist.setValue(CIVector(cgRect: ciImage.extent), forKey: kCIInputExtentKey)
    return hist.value(forKey: "outputData") as! Data
}

public func maxColorDiff(histogram: [UInt32]) -> Float {
    let rgb = stride(from: 0, to: histogram.count, by: 4).map { (index: Int)-> UInt32 in
        histogram[index] + histogram[index + 1] + histogram[index + 2]
    }
    if let last = rgb.lastIndex(where: { $0 > 0 }) {
        return Float(last) / Float(rgb.count)
    } else {
        return 1.0
    }
}

public func histogram(ciImage: CIImage) -> [UInt32] {
    let data = histogramData(ciImage)
    let count = data.count / MemoryLayout<UInt32>.stride
    let result: [UInt32] = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
        let pointer = bytes.bindMemory(to: UInt32.self)
        return Array(UnsafeBufferPointer(start: pointer.baseAddress, count: count))
    }
    return result
}