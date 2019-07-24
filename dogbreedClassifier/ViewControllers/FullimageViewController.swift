//
//  FullimageViewController.swift
//  dogbreedClassifier
//
//  Created by Tucker on 7/17/19.
//  Copyright © 2019 Tucker. All rights reserved.
//

import UIKit

class FullimageViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    

    @IBOutlet weak var dogCollections: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var topDogBreed:String?
    var allPicturesForRealatedDog:Pictures?
    let reuseIdentifier = "Ccell"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dogCollections.delegate = self
        dogCollections.dataSource = self
        self.title = topDogBreed
        let fixString = topDogBreed!.replacingOccurrences(of: "-", with: " ", options: .literal, range: nil)
        let search = fixDogName(fixString)

        let dogSearchUrl = buildUrl(dogBreed: search)
        print (dogSearchUrl)
        fetchDogs(dogUrl:dogSearchUrl.url!)

    }
    
    func reverseSentence(_ sentence: String) -> String {
        //create array of words
        let words = sentence.components(separatedBy: " ")
        var result = ""
        //append words to result with a space
        for word in words.reversed() {
            result += "\(word) "
        }
        return result
    }
    
    
    func fixDogName(_ sentence: String) -> String {
        //create array of words
        var mainBreed = ""
        var subBreed = ""
        let words = sentence.components(separatedBy: " ")
        var potentalMainbreeds: [String] = []
        var potentalSubbreeds: [String] = []
        for word in words.reversed(){
            
            let indexValueForKey = appDelegate.breeds?.message.index(forKey: word)
            
            if indexValueForKey != nil {
                
                let subBreed = appDelegate.breeds?.message[word]
                potentalMainbreeds.append(word)
                mainBreed = word
                if subBreed?.count == 0{
                    
                }else{
                    potentalSubbreeds.append(contentsOf:subBreed!)
                }
                
            }
            
        }
        
        for potental in potentalMainbreeds{
            
            let fault = appDelegate.breeds?.message[potental]
            for w in words{
                let new = fault?.contains(w)
                if new == true{
                    mainBreed = potental
                    subBreed = w
                }
            }
        }
        
        if subBreed == ""{
            return "\(mainBreed)"
        }else{
            return "\(mainBreed)/\(subBreed)"
        }
        
        
    }
    
    func fetchDogs(dogUrl:URL){
        get(url:dogUrl){ (output,response,error) in
            if output != nil {
                do{
                    try jsonDecoder(data: output!, type: Pictures.self){
                        (decodedPins) in
                        self.allPicturesForRealatedDog = decodedPins
                        self.activityIndicator.isHidden = false
                        self.dogCollections.reloadData()
                    }
                }catch{
                    
                }
            }else{
                print ("No data")
            }
            
        }
    }
    
    
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
        
        //print (allPicturesForRealatedDog!.message[indexPath.count])
        let url = NSURL(string: allPicturesForRealatedDog!.message[indexPath.item])
        photoForCell(imageUrl: url! as URL, cell: cell)
        
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = dogCollections.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
    }

    func photoForCell(imageUrl:URL,cell:CollectionViewCell) -> Void{
        get(url:imageUrl){ (output,response,error) in
            if output != nil{
                let data = output!
                // cast data as UIImage
                if let image = UIImage(data: data) {
        
                    cell.dogImageFromCeo.image = image
                    
                    // stop and hide indicator
                    //cell.aIndicator.stopAnimating()
                    cell.aIndicator.isHidden = true
                    
                
                }else{
                    print ("No data")
                }
            
            }else{
                print ("NO")
            }
        }
    }
    
}


