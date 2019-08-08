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
import Photos


// MARK: - UIImagePickerController
extension UIImagePickerController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.navigationBar.topItem?.rightBarButtonItem?.tintColor = UIColor.black
        self.navigationBar.topItem?.rightBarButtonItem?.isEnabled = true
    }
}


class dogClassifierViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource{
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var library: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var helpLabels: UILabel!
    @IBOutlet weak var helpLabelThree: UILabel!
    @IBOutlet weak var helpLabelTwo: UILabel!
    @IBOutlet weak var activityIndicatorLoadingNames: UIActivityIndicatorView!
    
    // MARK: - Class Prameters
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let imagePicker = UIImagePickerController()
    
    // table reusable identifier
    let tableReuseIdentifier = "Tcell"
    
    // trained model
    let model = ImageClassifier()
    
    // predicted dog-breeds for image
    var breedPredictionForImage:[String] = []
    
    // precents for predicted dog-breeds
    var breedPrecentForImage:[String] = []
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let defaults = UserDefaults.standard
        let hasAgreed = defaults.bool(forKey: "Agreed")
        if hasAgreed == false {
            performSegue(withIdentifier: "toAppInfo", sender: self)
        }
        
        appDelegate.breeds?.status = "unknown"
        
        // make request for all breeds and sub-breeds
        self.fetchDogBreeds(showError: false,completeSegue: false,withName: nil)
        
        
        // hide activity indicator
        self.activityIndicatorLoadingNames.isHidden = true
        
        // imagePicker delegate
        self.imagePicker.delegate = self
        
        // set background image
        self.imageView.image = UIImage(named:generateBackGroundImage())
        self.imageView.backgroundColor = generateBackGoundColor()
        
        // setup tableView
        self.tableView.backgroundColor = UIColor.black
        self.tableView.separatorColor = UIColor.black
        self.tableView.delegate = self
        self.tableView.dataSource = self


        // setup navigationBar
        self.title = "Dog Breed AI Classifier"
        
        // create bar button within navigationItem
        let refreshButton = UIBarButtonItem(barButtonSystemItem:.refresh, target: self, action: #selector(refeshButtonOnClick))
        self.navigationItem.rightBarButtonItem = refreshButton

        // check if device has a working camera
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    // MARK: - willTransition
    
    /// handles layout between portrait and landscape
    /// - Note: tableView is hidden when entering landscape mode
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            if UIApplication.shared.statusBarOrientation.isLandscape {
                self.tableView.isHidden = true
            } else {
                self.tableView.isHidden = false
            }
        })
    }
    
    // MARK: - Button modifiers
    
    /// IBActions for Camera/Library Bar buttons
    ///
    /// - Parameters:
    ///   - sender : Any
    
    @IBAction func chooseImageForPrediction(_ sender: Any) {
        let barButton = sender as! UIBarButtonItem
        
        if barButton.tag == 2{
            imagePicker.sourceType = .photoLibrary
        }else{
            imagePicker.sourceType = .camera
        }
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    /// reloads view to default
    
    @objc func refeshButtonOnClick() {
        
        // set imageView back to default
        self.imageView.image = UIImage(named:generateBackGroundImage())
        self.imageView.backgroundColor = generateBackGoundColor()
        self.imageView.contentMode = .scaleAspectFit
        
        // remove data from predictions and precents
        self.breedPredictionForImage.removeAll()
        self.breedPrecentForImage.removeAll()
        
        // reload tableView change backgound to black
        self.tableView.reloadData()
        self.tableView.backgroundColor = UIColor.black
        
        // help labels are shown
        self.helpLabels.isHidden = false
        self.helpLabelTwo.isHidden = false
        self.helpLabelThree.isHidden = false
    }
    
    /// presents perfromeSegueToPrivacyPoliciy
    @IBAction func appInfoButton(_ sender: Any) {
        performSegue(withIdentifier: "toAppInfo", sender:self)
    }
    
    // MARK: - random back-ground color
    
    /// random color is returned
    /// - Returns: UIImage
    
    private func generateBackGoundColor() -> UIColor {
        let names = [UIColor.blue, UIColor.green, UIColor.orange, UIColor.red, UIColor.yellow, UIColor.cyan, UIColor.magenta]
        let randomColor = names.randomElement()
        return randomColor!
    }
    
    // MARK: - random back-ground image
    
    /// returned string represents image asset
    /// - Returns: String
    
    private func generateBackGroundImage() -> String {
        let number = Int.random(in: 1 ... 17)
        return "dog\(number)"
    }
    
    
    
    /// MARK: - Model prediction modifiers
    ///
    /// Sets the UIImage for prediction
    ///
    /// - Parameters:
    ///   - picker: sets a image to a UIImagePickerController
    ///   - info: UIImage
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // present pick image
            self.imageView.contentMode = .scaleAspectFill
            self.imageView.image = pickedImage
            // enable refresh button
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            // hide help labels
            self.helpLabels.isHidden = true
            self.helpLabelTwo.isHidden = true
            self.helpLabelThree.isHidden = true
            // show table view
            self.tableView.backgroundColor = UIColor.white
            self.activityIndicatorLoadingNames.isHidden = false
            // reload table view
            self.breedPredictionForImage.removeAll()
            self.breedPrecentForImage.removeAll()
            self.tableView.reloadData()
            // pass image through model
            self.predictImage(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    /// fetch all dog-breeds
    ///
    /// - Parameters:
    ///   - showError : Bool allows error to be present to user
    ///   - completeSegue :Bool will complete segue if connection is made to the network
    ///   - withName : String of dog-breed name
    ///
    /// - Note: Because image predictions works offline network errors are not always shown
    
    private func fetchDogBreeds(showError:Bool,completeSegue:Bool?,withName:String?){
        get(url:breedComponents.url!){ (output,response,error) in
            if output != nil {
                do{
                    try jsonDecoder(data: output!, type: AllDogs.self){
                        (decodedDogBreed) in
                        self.appDelegate.breeds = decodedDogBreed
                        if completeSegue == true{
                            self.activityIndicatorLoadingNames.isHidden = true
                            self.performSegue(withIdentifier: "toDogCeo", sender: withName)
                        }
                    }
                    
                }catch{
                    error.alert(with: self)
                }
            }else if error != nil && showError == true{
                self.activityIndicatorLoadingNames.isHidden = true
                error!.alert(with: self)
            }
        }
    }
    
    /// make predictions for image with trained model
    ///
    /// - Parameters:
    ///   - image : UIImage
    
    private func predictImage(image:UIImage){
        DispatchQueue.global(qos: .userInitiated).async {
            // Resnet50 expects an image 299 x 299, so we should resize and crop the source image
            let inputImageSize: CGFloat = 299.0
            let minLen = min(image.size.width, image.size.height)
            let resizedImage = image.resize(to: CGSize(width: inputImageSize * image.size.width / minLen, height: inputImageSize * image.size.height / minLen))
            let cropedToSquareImage = resizedImage.cropToSquare()
            
            guard let pixelBuffer = cropedToSquareImage?.pixelBuffer() else {
                fatalError("Unexpected error.")
            }
            guard let classifierOutput = try? self.model.prediction(image: pixelBuffer) else {
                fatalError("Unexpected runtime error.")
            }
            
            DispatchQueue.main.async {
                
                let sortedByValueDictionary = classifierOutput.classLabelProbs.sorted { $0.1 > $1.1 }
                
                for dog in sortedByValueDictionary{
                    let value = Int(dog.value * 100)
                    if value > 0{
                        self.breedPrecentForImage.append("\(value) %")
                        let fixedName = fixErrorPhoneDogBreeds(name: dog.key)
                        self.breedPredictionForImage.append(fixedName)
                    }
                }
                self.activityIndicatorLoadingNames.isHidden = true
                self.tableView.reloadData()
                
            }
        }
    }
    
    
    
    /// MARK: - UITableViewDataSource protocol
    ///
    // tell the table view how many rows to make
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.breedPredictionForImage.count
    }
    
    // make a row for each meme struct in appDelegate array
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get a reference to our storyboard cell
        let cell = tableView.dequeueReusableCell(withIdentifier: tableReuseIdentifier, for: indexPath as IndexPath) as! TableViewCell
        
        // Use the outlet in our custom class to get a reference to the UIImage in the cell
        cell.breedLabel.text = self.breedPredictionForImage[indexPath.row]
        cell.precentLabel.text = self.breedPrecentForImage[indexPath.row]
        return cell
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if appDelegate.breeds?.status == "success"{
            performSegue(withIdentifier: "toDogCeo", sender: self.breedPredictionForImage[indexPath.item])
        }else{
            self.fetchDogBreeds(showError:true,completeSegue:true,withName:self.breedPredictionForImage[indexPath.item])
            self.activityIndicatorLoadingNames.isHidden = false
        }
    }
    
    // MARK: - prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toDogCeo") {
            let destinationVC = segue.destination as! DogBreedImageViewController
            destinationVC.topDogBreed = sender as? String
        }
    }
    
}

