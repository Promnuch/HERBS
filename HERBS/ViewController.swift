//
//  ViewController.swift
//  HERBS
//
//  Created by vsafe on 25/5/2562 BE.
//  Copyright © 2562 vsafe. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Vision
import AVKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var confidance: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    
    @IBAction func Pick(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let Herbs = Herbs8()
        
        
        if let model = try? VNCoreMLModel(for: Herbs.model){
            let request = VNCoreMLRequest(model: model) { (request,error) in
                if let result = request.results as? [VNClassificationObservation]{
                    for classification in result where classification.confidence > 0.5{
                        
                        let dataName = classification.identifier
                        let dataconfidance = classification.confidence*100
                        
                        self.name.text = ("Name: \(dataName)")
                        self.confidance.text = ("Confidance: \(dataconfidance)%")
                        
                        
                        let ref = Database.database().reference()
                        ref.child(dataName).observeSingleEvent(of: .value) { (snapshot) in
                            let data = snapshot.value as? [String:Any]
                            self.textView.text = "\(String(describing: data))"
                        }
                    }
                }
            }
            
            self.name.text = "Sorry!!! I don't know"
            self.confidance.text = nil
            self.textView.text = nil
            
            if let image = info[.originalImage] as? UIImage{
                imageView.image = image
                self.dismiss(animated: true, completion: nil)
                if let imageData = image.pngData(){
                    let handler = VNImageRequestHandler(data: imageData, options: [:])
                    try? handler.perform([request])
                    
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

