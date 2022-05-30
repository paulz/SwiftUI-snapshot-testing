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

func diff(_ old: CIImage, _ new: CIImage) -> CICompositeOperation {
    let differenceFilter: CICompositeOperation = CIFilter.differenceBlendMode()
    differenceFilter.inputImage = old.settingAlphaOne(in: old.extent)
    differenceFilter.backgroundImage = new.settingAlphaOne(in: new.extent)
    return differenceFilter
}

func histogramData(_ ciImage: CIImage) -> Data {
    let hist = CIFilter.areaHistogram()
    hist.inputImage = ciImage
    hist.setValue(CIVector(cgRect: ciImage.extent), forKey: kCIInputExtentKey)
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
    let delta = CIFilter.labDeltaE()
    delta.inputImage = image1
    delta.image2 = image2
    let diff2 = delta.outputImage!
    print(delta.outputKeys)
    print(delta.inputKeys)
    print(diff2.properties)
    let comp = PerceptiveColorDiff(difference: diff2)
    print(comp.maxColorDifference())
    return AbsoluteColorDiff(difference: diffOperation.outputImage!)
}

func compare(_ left: Data, _ right: Data) -> ImageComparisonResult {
    let options: [CIImageOption : Any] = [
        .colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
    ]
    let image1 = CIImage(data: left, options: options)!
        .premultiplyingAlpha()
    let image2 = CIImage(data: right, options: options)!
        .premultiplyingAlpha()
    
    let delta = CIFilter.labDeltaE()
    delta.inputImage = image1.settingAlphaOne(in: image1.extent)
    delta.image2 = image2.settingAlphaOne(in: image1.extent)
    let diff2 = delta.outputImage!
    print(delta.outputKeys)
    print(delta.inputKeys)
    print(diff2.properties)
    let comp = PerceptiveColorDiff(difference: diff2)
    print(comp.maxColorDifference())

    
    let diffOperation = diff(image1, image2)
    
    let minMax = CIFilter.areaMaximum()
    minMax.inputImage = diff2
    minMax.setValue(CIVector(cgRect: diff2.extent), forKey: kCIInputExtentKey)
    print(minMax.outputKeys)
    let maxImage = minMax.outputImage!

//    let context = CIContext(options: [.workingColorSpace : NSNull(), .outputColorSpace: NSNull()])
    let context = CIContext(options: [.workingColorSpace : CGColorSpace(name: CGColorSpace.sRGB)!, .outputColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!])
//    let context = CIContext()
    var data = Data([1,2,3,4])
    data.withUnsafeMutableBytes { ptr in
        context.render(maxImage, toBitmap: ptr.baseAddress!, rowBytes: 4, bounds: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)), format: .RGBA8, colorSpace: nil)
    }
    print("perception:", [UInt8](data))
    try! context.writePNGRepresentation(of: diff2, to: URL(fileURLWithPath: "/tmp/max.png"), format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
        //.pngRepresentation(of: maxImage, format: .RGBA8, colorSpace: nil)
    
    return AbsoluteColorDiff(difference: diffOperation.outputImage!)
}

protocol ImageComparisonResult {
    var difference: CIImage {get}
    
    func maxColorDifference() -> Float
}

struct PerceptiveColorDiff: ImageComparisonResult {
    let difference: CIImage
    
    func maxColorDifference() -> Float {
        maxColorDiff(histogram: histogram(ciImage: difference))
    }
}

struct AbsoluteColorDiff: ImageComparisonResult {
    let difference: CIImage
    
    func maxColorDifference() -> Float {
        maxColorDiff(histogram: histogram(ciImage: difference))
    }
}
