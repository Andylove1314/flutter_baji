import UIKit
import ImageIO
import MobileCoreServices

class ImageDpiUtil {
    static func saveImageWithDpi(_ image: UIImage, name: String, dpi: Int = 300, isJpg: Bool = true) -> String? {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        guard let cachePath = paths.first else { return nil }
        let fileURL = cachePath.appendingPathComponent(name)
        
        let type = isJpg ? kUTTypeJPEG : kUTTypePNG
        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, type, 1, nil) else {
            return nil
        }
        
        let finalImage: UIImage
        if isJpg {
            // 创建白色背景
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(UIColor.white.cgColor)
            context?.fill(CGRect(origin: .zero, size: image.size))
            image.draw(in: CGRect(origin: .zero, size: image.size))
            finalImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        } else {
            finalImage = image
        }
        
        let commonProperties: [CFString: Any] = [
            kCGImagePropertyDPIWidth: dpi,
            kCGImagePropertyDPIHeight: dpi,
            kCGImagePropertyPixelWidth: Int(finalImage.size.width * finalImage.scale),
            kCGImagePropertyPixelHeight: Int(finalImage.size.height * finalImage.scale)
        ]
        
        let formatProperties: [CFString: Any]
        if isJpg {
            formatProperties = [
                kCGImageDestinationLossyCompressionQuality: 1.0,
                kCGImagePropertyDPIWidth: dpi,
                kCGImagePropertyDPIHeight: dpi,
                kCGImagePropertyTIFFDictionary: [
                    kCGImagePropertyTIFFXResolution: dpi,
                    kCGImagePropertyTIFFYResolution: dpi,
                    kCGImagePropertyTIFFResolutionUnit: 2
                ] as [CFString: Any]
            ]
        } else {
            formatProperties = [
                kCGImagePropertyPNGDictionary: [
                    kCGImagePropertyPNGXPixelsPerMeter: Int(Double(dpi) * 39.37),
                    kCGImagePropertyPNGYPixelsPerMeter: Int(Double(dpi) * 39.37),
                    kCGImagePropertyPNGInterlaceType: 0
                ] as [CFString: Any]
            ]
        }
        
        let properties = commonProperties.merging(formatProperties) { $1 }
        
        CGImageDestinationAddImage(destination, finalImage.cgImage!, properties as CFDictionary)
        
        if CGImageDestinationFinalize(destination) {
            return fileURL.path
        }
        
        return nil
    }
}