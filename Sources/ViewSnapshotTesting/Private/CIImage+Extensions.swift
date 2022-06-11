import CoreImage

extension CIImage {
    func adjustExposure(amount: Float) -> CIImage {
        guard amount < 0.5 else {
            return self
        }
        let filter = CIFilter.exposureAdjust()
        filter.inputImage = self
        filter.ev = log2(1/amount) * 2
        return filter.outputImage!
    }
}
