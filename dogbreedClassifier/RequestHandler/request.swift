//
//  request.swift
//  dogbreedClassifier
//
//  Created by Tucker on 7/17/19.
//  Copyright © 2019 Tucker. All rights reserved.
//

import Foundation

// MARK: - Endpoints

struct dogEndpoint {
    static let scheme = "https"
    static let host = "dog.ceo"
    static let path = "/api/breed"
}
struct allbreedsEndpoint {
    static let scheme = "https"
    static let host = "dog.ceo"
    static let path = "/api/breeds/list/all"
}

var breedComponents:URLComponents{
    var components = URLComponents()
    components.scheme = allbreedsEndpoint.scheme
    components.host = allbreedsEndpoint.host
    components.path = allbreedsEndpoint.path
    return components
}


// MARK: - CodeableStructs
struct AllDogs: Codable {
    let message: [String: [String]]
    var status: String
}

struct Pictures: Codable {
    let message: [String]
    let status: String
}

// MARK: - jsonDecoder
func jsonDecoder<T : Codable>(data:Data,type:T.Type, completionHandler:@escaping (_ details: T) -> Void)throws  {
    let copyData = data
    let decoder = JSONDecoder()
    do {
        let jsonEncode = try decoder.decode(type, from:copyData)
        completionHandler(jsonEncode)
    } catch {
        throw error
    }
}

// MARK: - buildUrl
func buildUrl(dogBreed:String) -> URLComponents{
    
    var components = URLComponents()
    components.scheme = dogEndpoint.scheme
    components.host = dogEndpoint.host
    components.path = dogEndpoint.path + "/" + dogBreed + "/images"

    return components
}

// MARK: - getRequst
public func get(url:URL,completionBlock:  @escaping  (Data?,URLResponse?,Error?)  -> Void)  -> Void {
    var request = URLRequest(url:url,timeoutInterval: 50.0)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let session = URLSession.shared
    let task = session.dataTask(with: request) {data,response,error in
        DispatchQueue.main.async  {
            completionBlock(data,response ,error)
        }
    }
    task.resume()
}




