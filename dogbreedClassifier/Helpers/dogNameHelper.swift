//
//  dogNameHelper.swift
//  dogbreedClassifier
//
//  Created by Tucker on 7/24/19.
//  Copyright © 2019 Tucker. All rights reserved.
//

import Foundation

/// 2d array holding error-prone dog-breed names
/// - Note: [ apiEndPointName, modelPredictionName ]

let matchBreed = [
    ["boston bulldog","boston bull"],
    ["english hound","english foxhound"],
    ["stbernard","saint bernard"],
    ["cardigan corgi","cardigan"],
    ["mexicanhairless","mexican hairless"],
    ["westhighland terrier","west highland white terrier"],
    ["dandie terrier","dandie dinmont"],
    ["shihtzu","shih-tzu"],
    ["kerryblue terrier","kerry blue terrier"],
    ["scottish terrier","scotch terrier"],
    ["flatcoated retriever","flat-coated retriever"],
    ["blood hound","bloodhound"],
    ["basset hound","basset"],
    ["germanshepherd","german shepherd"]
]

/// fixes error-prone breeds
/// - Parameters:
///   - name : String
/// - Returns:
///   - modifiedName : String

func fixErrorPhoneDogBreeds(name:String) -> String{
    var modifiedName = String(name.dropFirst(10))
    modifiedName = modifiedName.lowercased()
    modifiedName = modifiedName.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)
    for dog in matchBreed{
        if dog[1] == modifiedName{
            modifiedName = dog[0]
        }
    }
    return modifiedName
}

/// match api subbreed and mainbreeds to predicted breed output
/// - Parameters:
///   - sentence: String
///   - breeds: AllDogs (api breed-names)
/// - Returns:
///   - String: String (used as url path)

func fixBreedName(_ predictedBreed: String, breeds:AllDogs?) -> String {
    
    var mainBreed = ""
    var subBreed = ""
    let separateBreedName = predictedBreed.components(separatedBy: " ")
    var potentalMainbreeds: [String] = []
    var potentalSubbreeds: [String] = []
    
    for breed in separateBreedName.reversed(){
        let indexValueForKey = breeds?.message.index(forKey: breed)
        if indexValueForKey != nil {
            let subBreed = breeds?.message[breed]
            potentalMainbreeds.append(breed)
            mainBreed = breed
            if subBreed?.count != 0{
                potentalSubbreeds.append(contentsOf:subBreed!)
            }
        }
    }
    
    for main in potentalMainbreeds{
        let subBreedsListFromMain = breeds?.message[main]
        for sub in separateBreedName{
            let new = subBreedsListFromMain?.contains(sub)
            if new == true{
                mainBreed = main
                subBreed = sub
            }
        }
    }
    
    if subBreed == ""{
        return "\(mainBreed)"
    }else{
        return "\(mainBreed)/\(subBreed)"
    }
    
}
