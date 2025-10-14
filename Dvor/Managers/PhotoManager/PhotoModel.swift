import Foundation

enum PhotoError: Error, LocalizedError, Equatable {
    case noCameraAvailable
    case noPhotoSelected
    case permissionDenied
    case unknownError
    case cancelled
    case sizeExceeded(maxSize: Int)
    
    var errorDescription: String? {
        switch self {
        case .noCameraAvailable: return "Камера недоступна"
        case .noPhotoSelected: return "Фото не выбрано"
        case .permissionDenied: return "Доступ к галерее запрещен"
        case .unknownError: return "Неизвестная ошибка"
        case .cancelled: return "Выбор отменен"
        case .sizeExceeded(let maxSize):
            let sizeInMB = maxSize / (1024 * 1024)
            return "Размер фото превышает \(sizeInMB) MB"
        }
    }
}
