//
//  ImagePicker.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 27/11/25.
//


import SwiftUI
import PhotosUI



struct ImagePicker: UIViewControllerRepresentable {
    enum SourceType {
        case camera, gallery
    }
    
    @Binding var selectedImage: UIImage?
    var sourceType: SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        
        switch sourceType {
        case .camera:
            picker.sourceType = .camera
        case .gallery:
            picker.sourceType = .photoLibrary
        }
        
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
    }
}
