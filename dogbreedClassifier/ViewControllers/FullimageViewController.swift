//
//  FullimageViewController.swift
//  dogbreedClassifier
//
//  Created by Tucker on 7/17/19.
//  Copyright © 2019 Tucker. All rights reserved.
//

import UIKit

class FullimageViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    // MARK: - IBOutlets
    @IBOutlet weak var dogCollections: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Class parameters
    var topDogBreed:String?
    var allPicturesForRealatedDog:Pictures?
    let reuseIdentifier = "Ccell"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup collectionView
        dogCollections.delegate = self
        dogCollections.dataSource = self
        
        // show activityIndicator
        self.activityIndicator.isHidden = false
        
        // setup dog breed
        self.title = topDogBreed
        let fixString = topDogBreed!.replacingOccurrences(of: "-", with: " ", options: .literal, range: nil)
        
        // fix dog breed to match api documentation
        let search = fixBreedName(fixString,breeds:appDelegate.breeds)
        
        // build url and send request for dog breed
        let dogSearchUrl = buildUrl(dogBreed: search)
        fetchDogs(dogUrl:dogSearchUrl.url!)
    }
    
    
    //MARK: - viewWillTransition
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = dogCollections.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
    }
    
    
    // MARK: - CollectionView protocol
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPicturesForRealatedDog?.message.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfCellsInRow = 2
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // set reusable cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CollectionViewCell
        
        // set placeholder image
        cell.dogImageFromCeo.image = UIImage(named: "icon")
        
        // request for image related to each cell
        let url = NSURL(string: allPicturesForRealatedDog!.message[indexPath.item])
        imageForEachCell(imageUrl: url! as URL, cell: cell)
        
        return cell
    }
    
    
    // MARK: - Class request modifiers
    
    /// Get request for dog-breed image urls
    ///
    /// - Parameters:
    ///   - dogUrl : dog-breed url
    /// - Note: dogUrl's are created from buildUrl modifier
    
    func fetchDogs(dogUrl:URL){
        get(url:dogUrl){ (output,response,error) in
            if output != nil {
                do{
                    try jsonDecoder(data: output!, type: Pictures.self){
                        (decodedPins) in
                        self.allPicturesForRealatedDog = decodedPins
                        self.activityIndicator.isHidden = true
                        self.dogCollections.reloadData()
                    }
                }catch{
                    error.alert(with: self)
                    self.activityIndicator.isHidden = true
                }
            }else{
                error?.alert(with: self)
                self.activityIndicator.isHidden = true
            }
            
        }
    }

    /// Get request for dog-breed image
    ///
    /// - Parameters:
    ///   - imageUrl: image url
    ///   - cell: cell the image should be loaded
    /// - Note: imageUrl is used to request the dog-breed image loaded to UIImage View
    
    func imageForEachCell(imageUrl:URL,cell:CollectionViewCell) -> Void{
        get(url:imageUrl){ (output,response,error) in
            if output != nil{
                let data = output!
                // cast data as UIImage
                if let image = UIImage(data: data) {
                    cell.dogImageFromCeo.image = image
                    cell.activityIndicator.isHidden = true

                }else{
                    error?.alert(with: self)
                }
            
            }else{
                error?.alert(with:self)
            }
        }
    }
    
}
