import UIKit
import PhotosUI

protocol PhotoManagerProtocol: AnyObject {
    func pickPhoto(from router: RouterMainProtocol?,
                  maxSize: Int?,
                  completion: @escaping (Result<UIImage, PhotoError>) -> Void)
    func showPhotoPickerOptions(from router: RouterMainProtocol,
                               maxSize: Int?,
                               completion: @escaping (Result<UIImage, PhotoError>) -> Void)
}

final class PhotoManager: NSObject {
    
    // MARK: - Properties
    private var router: RouterMainProtocol?
    private var completion: ((Result<UIImage, PhotoError>) -> Void)?
    private var allowsEditing: Bool = true
    private var maxSize: Int?
    
    deinit {
        // print("Deinit PhotoManager")
    }
}

// MARK: - PhotoManagerProtocol
extension PhotoManager: PhotoManagerProtocol {
    
    // MARK: - Call Pick Photo
    func pickPhoto(from router: RouterMainProtocol?,
                   maxSize: Int? = nil,
                   completion: @escaping (Result<UIImage, PhotoError>) -> Void) {
        
        self.router = router
        self.completion = completion
        self.maxSize = maxSize
        
        guard let router else {return}
        showPhotoPickerOptions(from: router, maxSize: maxSize, completion: completion)
    }
    
    // MARK: - Show Alert For Photo Picker
    func showPhotoPickerOptions(from router: RouterMainProtocol,
                               maxSize: Int? = nil,
                               completion: @escaping (Result<UIImage, PhotoError>) -> Void) {
        
        self.router = router
        self.completion = completion
        self.maxSize = maxSize
        
        let alert = UIAlertController(title: "Choose a photo".loc, message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Make a photo".loc, style: .default) { [weak self] _ in
                self?.openCamera()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Choose from the gallery".loc, style: .default) { [weak self] _ in
            self?.openModernGallery()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel".loc, style: .cancel) { [weak self] _ in
            self?.completion?(.failure(.cancelled))
        })
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = router.navigationController.view
            popoverController.sourceRect = CGRect(x: router.navigationController.view.bounds.midX,
                                                y: router.navigationController.view.bounds.midY,
                                                width: 0, height: 0)
        }
        
        router.presentVC(alert)
    }
}

// MARK: - Private Methods
private extension PhotoManager {
    
    //MARK: - Checking the image size
    private func checkImageSize(_ image: UIImage) -> Bool {
        guard let maxSize = maxSize else { return true }
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return false
        }
        
        let imageSize = imageData.count
        print("Image size: \(imageSize) bytes, limit: \(maxSize) bytes")
        
        return imageSize <= maxSize
    }
    
    //MARK: - Processing of the selected image with size verification
    private func handleSelectedImageWithSizeCheck(_ image: UIImage) {
        if checkImageSize(image) {
            completion?(.success(image))
        } else {
            completion?(.failure(.sizeExceeded(maxSize: maxSize ?? 0)))
        }
        cleanup()
    }
    
    //MARK: - Camera
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            completion?(.failure(.noCameraAvailable))
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = allowsEditing
        picker.cameraDevice = .front
        
        router?.presentVC(picker)
    }
    
    //MARK: - Gallery
    private func openModernGallery() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        setupPickerDismissHandler(picker)
        
        router?.presentVC(picker)
    }
    
    //MARK: - Selected error
    private func handleError(_ error: PhotoError) {
        completion?(.failure(error))
        cleanup()
    }
    
    //MARK: - clean reference
    private func cleanup() {
        router = nil
        completion = nil
        maxSize = nil
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension PhotoManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            if let editedImage = info[.editedImage] as? UIImage {
                self.handleSelectedImageWithSizeCheck(editedImage)
            } else if let originalImage = info[.originalImage] as? UIImage {
                self.handleSelectedImageWithSizeCheck(originalImage)
            } else {
                self.handleError(.noPhotoSelected)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [weak self] in
            self?.handleError(.cancelled)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension PhotoManager: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let hasResults = !results.isEmpty
        
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            if hasResults {
                self.processPickerResults(results)
            } else {
                self.handleError(.cancelled)
            }
        }
    }
    
    private func processPickerResults(_ results: [PHPickerResult]) {
        guard let result = results.first else {
            self.handleError(.noPhotoSelected)
            return
        }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self.handleSelectedImageWithSizeCheck(image)
                }
            } else if error != nil {
                DispatchQueue.main.async {
                    self.handleError(.unknownError)
                }
            } else {
                DispatchQueue.main.async {
                    self.handleError(.noPhotoSelected)
                }
            }
        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension PhotoManager: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        handleError(.cancelled)
    }
    
    func setupPickerDismissHandler(_ picker: PHPickerViewController) {
        picker.presentationController?.delegate = self
    }
}

// MARK: - Constants
    struct SizeLimits {
        static let mb1 = 1024 * 1024 // 1 MB
        static let mb2 = 2 * 1024 * 1024 // 2 MB
        static let mb3 = 3 * 1024 * 1024 // 3 MB
        static let mb8 = 8 * 1024 * 1024 // 8 MB
    }

