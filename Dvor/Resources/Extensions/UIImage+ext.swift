import UIKit


extension UIImage {
    enum ImageFormat {
        case png
        case jpeg(compressionQuality: CGFloat)
    }
    
    func toData(format: ImageFormat = .jpeg(compressionQuality: 0.8)) -> Data? {
        switch format {
        case .png:
            return pngData()
        case .jpeg(let quality):
            return jpegData(compressionQuality: quality)
        }
    }
}
