//
//  ViewController.swift
//  dogbreedClassifier
//
//  Created by Tucker on 7/16/19.
//  Copyright © 2019 Tucker. All rights reserved.
//

import UIKit
import Foundation
import CoreML
import Vision


extension UIImagePickerController {
    // show cancel button
    // this needs to be checked
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.navigationBar.topItem?.rightBarButtonItem?.tintColor = UIColor.black
        self.navigationBar.topItem?.rightBarButtonItem?.isEnabled = true
    }
}

extension UIImage {
    // resize image to fit model
    func resize(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), true, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    func cropToSquare() -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        var imageHeight = self.size.height
        var imageWidth = self.size.width
        
        if imageHeight > imageWidth {
            imageHeight = imageWidth
        }
        else {
            imageWidth = imageHeight
        }
        
        let size = CGSize(width: imageWidth, height: imageHeight)
        
        let x = ((CGFloat(cgImage.width) - size.width) / 2).rounded()
        let y = ((CGFloat(cgImage.height) - size.height) / 2).rounded()
        
        let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
        if let croppedCgImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCgImage, scale: 0, orientation: self.imageOrientation)
        }
        
        return nil
    }
    
    func pixelBuffer() -> CVPixelBuffer? {
        let width = self.size.width
        let height = self.size.height
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        
        guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
                                        return nil
        }
        
        context.translateBy(x: 0, y: height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return resultPixelBuffer
    }
}



class dogClassifierViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var library: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var helpLabels: UILabel!
    @IBOutlet weak var helpLabelThree: UILabel!
    @IBOutlet weak var helpLabelTwo: UILabel!
    @IBOutlet weak var activityIndicatorLoadingNames: UIActivityIndicatorView!
    
    var imageInCoot:UIImage?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let imagePicker = UIImagePickerController()
    let tableReuseIdentifier = "Tcell"
    let model = ImageClassifier()
    var allPredictions:[String] = []
    var allprecent:[String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicatorLoadingNames.isHidden = true
        self.fetchDogBreeds(dogUrl: breedComponents.url!)
        
        self.imagePicker.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.title = "Dog Classifier"
        self.tableView.backgroundColor = UIColor.black
        self.tableView.separatorColor = UIColor.black
        let btnShare = UIBarButtonItem(barButtonSystemItem:.action, target: self, action: #selector(btnShareClicked))
        let refeshButton = UIBarButtonItem(barButtonSystemItem:.refresh, target: self, action: #selector(btnRefesh))
        self.navigationItem.leftBarButtonItem = refeshButton
        self.navigationItem.rightBarButtonItem = btnShare
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)

    }
    

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            if UIApplication.shared.statusBarOrientation.isLandscape {
                self.tableView.isHidden = true
            } else {
                self.tableView.isHidden = false
            }
        })
    }
    
    @objc func btnRefesh() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        imageView.image = UIImage(named:"icon")
        allPredictions.removeAll()
        allprecent.removeAll()
        tableView.reloadData()
        helpLabels.isHidden = false
        helpLabelTwo.isHidden = false
        helpLabelThree.isHidden = false
        self.tableView.backgroundColor = UIColor.black
    }
    
    @objc func btnShareClicked() {
        let image = generateImageWithBreeds()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.popoverPresentationController?.sourceView = self.view
        present(controller,animated:true,completion:nil)
    }
    
    func fetchDogBreeds(dogUrl:URL){
        get(url:dogUrl){ (output,response,error) in
            if output != nil {
                do{
                    try jsonDecoder(data: output!, type: AllDogs.self){
                        (decodedDogBreed) in
                        self.appDelegate.breeds = decodedDogBreed
                    }
                    
                }catch{
                    error.alert(with: self)
                }
            }else if error != nil {
                error!.alert(with: self)
            }
        }
    }
    
   
    
    @IBAction func chooseImage(_ sender: Any) {

            let barButton = sender as! UIBarButtonItem
            
            if barButton.tag == 2{
                imagePicker.sourceType = .photoLibrary
            }else{
                imagePicker.sourceType = .camera
            }

            self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    /// Sets the UIImage
    ///
    /// - Parameters:
    ///   - picker: sets a image to a UIImagePickerController
    ///   - info: UIImage
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // MARK: PickImage
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            self.imageView.contentMode = .scaleAspectFit
            self.imageView.image = pickedImage
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            helpLabels.isHidden = true
            helpLabelTwo.isHidden = true
            helpLabelThree.isHidden = true
            self.tableView.backgroundColor = UIColor.white
            self.activityIndicatorLoadingNames.isHidden = false
            self.predictImage(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func fixDogName(name:String) -> String{
        let lname = name.lowercased()
        let fixString = lname.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)
        return fixString
    }
    
    
    
    func matchDogName(name:String) -> String{
        var fixedName = name
        if name == "boston bull"{
            fixedName = "boston bulldog"
        }
        if name == "english foxhound"{
            fixedName = "english hound"
        }
        if name == "saint bernard" {
            fixedName = "stbernard"
        }
        if name == "cardigan"{
            fixedName = "cardigan corgi"
        }
        if name == "mexican hairless"{
            fixedName = "mexicanhairless"
        }
        if name == "west highland white terrier"{
            fixedName = "westhighland terrier"
        }
        if name == "dandie dinmont"{
            fixedName = "dandie terrier"
        }
        if name == "shih-tzu"{
            fixedName = "shihtzu"
        }
        if name == "kerry blue terrier"{
            fixedName = "kerryblue terrier"
        }
        if name == "scotch terrier"{
            fixedName = "scottish terrier"
        }
        return fixedName
    }

    func predictImage(image:UIImage){
        DispatchQueue.global(qos: .userInitiated).async {
            // Resnet50 expects an image 299 x 299, so we should resize and crop the source image
            let inputImageSize: CGFloat = 299.0
            let minLen = min(image.size.width, image.size.height)
            let resizedImage = image.resize(to: CGSize(width: inputImageSize * image.size.width / minLen, height: inputImageSize * image.size.height / minLen))
            let cropedToSquareImage = resizedImage.cropToSquare()
            
            guard let pixelBuffer = cropedToSquareImage?.pixelBuffer() else {
                fatalError("incorrect picture size")
            }
            guard let classifierOutput = try? self.model.prediction(image: pixelBuffer) else {
                fatalError("Unexpected runtime error.")
            }
            
            DispatchQueue.main.async {
                
                let sortedByValueDictionary = classifierOutput.classLabelProbs.sorted { $0.1 > $1.1 }
                self.allPredictions.removeAll()
                self.allprecent.removeAll()
                
                for dog in sortedByValueDictionary{
                    let value = Int(dog.value * 100)
                    if value > 0{
                        self.allprecent.append("\(value) %")
                        var fixedName = self.fixDogName(name:String(dog.key.dropFirst(10)))
                        fixedName = self.matchDogName(name:fixedName)
                        
                        self.allPredictions.append(fixedName)
                    }
                }
                self.activityIndicatorLoadingNames.isHidden = true
                self.tableView.reloadData()
                
            }
        }
    }
    
    
    
    // MARK: - UITableViewDataSource protocol
    
    // tell the table view how many rows to make
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.allPredictions.count
    }
    
    // make a row for each meme struct in appDelegate array
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get a reference to our storyboard cell
        let cell = tableView.dequeueReusableCell(withIdentifier: tableReuseIdentifier, for: indexPath as IndexPath) as! TableViewCell
        
        // Use the outlet in our custom class to get a reference to the UIImage in the cell
        cell.breedLabel.text = self.allPredictions[indexPath.row] 
        cell.precentLabel.text = self.allprecent[indexPath.row]
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if appDelegate.breeds?.message.count != 0 {
            performSegue(withIdentifier: "toDogCeo", sender: self.allPredictions[indexPath.item])
        }else{
            self.fetchDogBreeds(dogUrl: breedComponents.url!)
        }
    }
    
    
    func generateImageWithBreeds() -> UIImage {
        
        configureBars(true) //tool,navi bar are hidden during the render of meme
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        configureBars(false)
        return memedImage
    }
    
    func configureBars(_ isHidden: Bool){
        navigationController?.setNavigationBarHidden(isHidden, animated: false)
        self.toolbar.isHidden = isHidden
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toDogCeo") {
            let destinationVC = segue.destination as! FullimageViewController
            destinationVC.topDogBreed = sender as? String
        }
    }
    
}

