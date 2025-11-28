//
//  ImagePicker.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 27/11/25.
//


import SwiftUI
import PhotosUI
import CropViewController

struct ImagePicker: UIViewControllerRepresentable {
    enum SourceType {
        case camera, gallery
    }
    
    @Binding var selectedImage: UIImage?
    var sourceType: SourceType

    var onCrop: ((UIImage) -> Void)? = nil
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        
        picker.sourceType = (sourceType == .camera) ? .camera : .photoLibrary
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
        
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // MARK: - Image Selected
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            picker.dismiss(animated: true)

            if let image = info[.originalImage] as? UIImage {
                // Show crop controller
                let cropVC = CropViewController(image: image)
                cropVC.delegate = self

                // Make circle crop
             
                cropVC.aspectRatioLockEnabled = true
                cropVC.resetAspectRatioEnabled = true
               
                
                // Present on top controller
                if let topVC = UIApplication.shared.keyWindow?.rootViewController {
                    topVC.present(cropVC, animated: true)
                }
            }
        }

        // MARK: - Cropped Result
        func cropViewController(_ cropViewController: CropViewController,
                                didCropToImage image: UIImage,
                                withRect cropRect: CGRect,
                                angle: Int) {
            
            parent.selectedImage = image
            parent.onCrop?(image)
            cropViewController.dismiss(animated: true)
        }
        
    }
}


extension UIApplication {

    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
