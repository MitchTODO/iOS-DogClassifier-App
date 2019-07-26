//
//  AppDelegate.swift
//  dogbreedClassifier
//
//  Created by Tucker on 7/16/19.
//  Copyright © 2019 Tucker. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // hold current dog breeds and subbreeds offered by api 
    var breeds:AllDogs?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
}

