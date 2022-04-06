//
//  ViewController.swift
//  ImageID
//
//  Created by Karen Turner on 4/6/22.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageViewBackground: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userChosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageViewBackground.image = userChosenImage
            
            guard let ciImage = CIImage(image: userChosenImage) else {
                fatalError("Error converting image to CIImage")
            }
            
            detect(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: MobileNetV2FP16().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as?[VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            print(results)
            
             if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog"
                }
                else {
                    self.navigationItem.title = "Not Hotdog"
                    self.navigationItem.title = firstResult.identifier
                }
            
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
        try handler.perform([request])
        } catch {
            print(error)
        }
    }

    @IBAction func albumButtonPressed(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
}

