import Foundation

fileprivate struct PhotoPickerStrings {
    static let noCameraAvailable = "photo_picker.no_camera_available".loc
    static let noPhotoSelected = "photo_picker.no_photo_selected".loc
    static let permissionDenied = "photo_picker.permission_denied".loc
    static let unknownError = "photo_picker.unknown_error".loc
    static let cancelled = "photo_picker.cancelled".loc
    static let sizeExceeded = "photo_picker.size_exceeded".loc
}

enum PhotoError: Error, LocalizedError, Equatable {
    case noCameraAvailable
    case noPhotoSelected
    case permissionDenied
    case unknownError
    case cancelled
    case sizeExceeded(maxSize: Int)
    
    var errorDescription: String? {
        switch self {
        case .noCameraAvailable:
            return PhotoPickerStrings.noCameraAvailable

        case .noPhotoSelected:
            return PhotoPickerStrings.noPhotoSelected

        case .permissionDenied:
            return PhotoPickerStrings.permissionDenied

        case .unknownError:
            return PhotoPickerStrings.unknownError

        case .cancelled:
            return PhotoPickerStrings.cancelled

        case .sizeExceeded(let maxSize):
            let sizeInMB = maxSize / (1024 * 1024)
            return String(format: PhotoPickerStrings.sizeExceeded, sizeInMB)
        }
    }
}
