//
//  ViewController.swift
//  PictureProtector
//
//  Created by Sampath on 7/20/18.
//  Copyright © 2018 sky. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    var inputImage:UIImage?
    
    var detectedFaces = [(observation:VNFaceObservation, blur:Bool)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Import", style: .plain, target: self, action: #selector(importPhoto))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePhoto))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func importPhoto(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {return}
        
        imageView.image = image
        inputImage = image
        
        dismiss(animated: true) {
            self.detectFaces()
        }
    }
    
    func detectFaces(){
        guard let inputImage = inputImage else { return }
        guard let ciImage = CIImage(image: inputImage) else { return }
        
        let request = VNDetectFaceRectanglesRequest { [weak self] request,error in
            if let error = error{
                print(error.localizedDescription)
            }
            else{
                guard let observations = request.results as? [VNFaceObservation] else {return}
                self?.detectedFaces = Array(zip(observations, [Bool](repeating: false, count: observations.count)))
                self?.addBlurRects()
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addBlurRects(){
        imageView.subviews.forEach{ $0.removeFromSuperview()}
        let imageRect = imageView.contentClippingRect
        
        for (index,face) in detectedFaces.enumerated(){
            let boundingBox = face.observation.boundingBox
            let size = CGSize(width: boundingBox.width * imageRect.width, height: boundingBox.height * imageRect.height)
            var origin = CGPoint(x: boundingBox.minX * imageRect.width, y: (1 - face.observation.boundingBox.minY) * imageRect.height - size.height)
            origin.y += imageRect.minY
            let vw = UIView(frame: CGRect(origin: origin, size: size))
            vw.tag = index
            vw.layer.borderColor = UIColor.red.cgColor
            vw.layer.borderWidth = 2
            imageView.addSubview(vw)
            
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(faceTapped))
            vw.addGestureRecognizer(recognizer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        addBlurRects()
    }
    
    func renderBlurredFaces(){
        guard let currentUIImage = inputImage else { return }
        guard let currentCGImage = currentUIImage.cgImage else { return }
        let currentCIImage = CIImage(cgImage: currentCGImage)
        
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        filter?.setValue(12, forKey: kCIInputScaleKey)
        
        guard let outputImage = filter?.outputImage  else { return }
        let blurredImage = UIImage(ciImage: outputImage)
        
        let renderer = UIGraphicsImageRenderer(size: currentUIImage.size)
        
        let result = renderer.image { ctx in
            currentUIImage.draw(at: .zero)
            let path = UIBezierPath()
            
            for face in detectedFaces{
                if face.blur{
                    let boundingBox = face.observation.boundingBox
                    let size = CGSize(width: boundingBox.width * currentUIImage.size.width, height: boundingBox.height * currentUIImage.size.height)
                    var origin = CGPoint(x: boundingBox.minX * currentUIImage.size.width, y: (1 - face.observation.boundingBox.minY) * currentUIImage.size.height - size.height)
                    
                    let rect = CGRect(origin: origin, size: size)
                    
                    let miniPath = UIBezierPath(rect: rect)
                    path.append(miniPath)
                }
            }
            
            if !path.isEmpty{
                path.addClip()
                blurredImage.draw(at: .zero)
            }
        }
        imageView.image = result
    }
    
    @objc func faceTapped(_ sender:UITapGestureRecognizer){
        guard let vw = sender.view else { return }
        detectedFaces[vw.tag].blur = !detectedFaces[vw.tag].blur
        renderBlurredFaces()
    }
    
    @objc func sharePhoto(){
        guard let img = imageView.image else { return }
        let ac = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        present(ac,animated: true)
    }
}
