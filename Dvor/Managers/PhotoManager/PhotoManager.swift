import UIKit
import PhotosUI


enum PhotoError: Error, LocalizedError {
    case noCameraAvailable
    case noPhotoSelected
    case permissionDenied
    case unknownError
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .noCameraAvailable: return "Камера недоступна"
        case .noPhotoSelected: return "Фото не выбрано"
        case .permissionDenied: return "Доступ к галерее запрещен"
        case .unknownError: return "Неизвестная ошибка"
        case .cancelled: return "Выбор отменен"
        }
    }
}


protocol PhotoManagerProtocol: AnyObject {
    func pickPhoto(from router: RouterMainProtocol?,
                  completion: @escaping (Result<UIImage, PhotoError>) -> Void)
    func showPhotoPickerOptions(from router: RouterMainProtocol,
                               completion: @escaping (Result<UIImage, PhotoError>) -> Void)
}

final class PhotoManager: NSObject {
    
    // MARK: - Properties
    private var router: RouterMainProtocol?
    private var completion: ((Result<UIImage, PhotoError>) -> Void)?
    private var allowsEditing: Bool = true
        
    deinit {
        print("Deinit PhotoManager")
    }
}

// MARK: - PhotoManagerProtocol
extension PhotoManager: PhotoManagerProtocol {
    
    // MARK: - Call Pick Photo
    func pickPhoto(from router: RouterMainProtocol?,
                   completion: @escaping (Result<UIImage, PhotoError>) -> Void) {
        
        self.router = router
        self.completion = completion
        
        guard let router else {return}
        showPhotoPickerOptions(from: router, completion: completion)
        
    }
    
    // MARK: - Show Alert For Photo Picker
    func showPhotoPickerOptions(from router: RouterMainProtocol,
                               completion: @escaping (Result<UIImage, PhotoError>) -> Void) {
        
        self.router = router
        self.completion = completion
        
        let alert = UIAlertController(title: "Выбрать фото", message: nil, preferredStyle: .actionSheet)
        
        // Камера
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Сделать фото", style: .default) { [weak self] _ in
                self?.openCamera()
            })
        }
        
        // Галерея
        alert.addAction(UIAlertAction(title: "Выбрать из галереи", style: .default) { [weak self] _ in
            self?.openModernGallery()
        })
        
        // Отмена
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { [weak self] _ in
            self?.completion?(.failure(.cancelled))
        })
        
//         Для iPad
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = router.navigationController.view
            popoverController.sourceRect = CGRect(x: router.navigationController.view.bounds.midX,
                                                y: router.navigationController.view.bounds.midY,
                                                width: 0, height: 0)
        }
        
        router.present(alert)
    }
}

// MARK: - Private Methods
private extension PhotoManager {
    
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
        
        router?.present(picker)
    }
    
    //MARK: - Gallery
    private func openModernGallery() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        setupPickerDismissHandler(picker)
        
        router?.present(picker)
    }
    
    //MARK: - Selected Image
    private func handleSelectedImage(_ image: UIImage) {
        completion?(.success(image))
        cleanup()
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
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension PhotoManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            if let editedImage = info[.editedImage] as? UIImage {
                self.handleSelectedImage(editedImage)
            } else if let originalImage = info[.originalImage] as? UIImage {
                self.handleSelectedImage(originalImage)
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
                    self.handleSelectedImage(image)
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

//MARK: -  UIAdaptivePresentationControllerDelegate
extension PhotoManager: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        //For swipe picker
        handleError(.cancelled)
    }
    
    // For dismiss delegate
    func setupPickerDismissHandler(_ picker: PHPickerViewController) {
        picker.presentationController?.delegate = self
    }
}
