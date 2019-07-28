//
//  errorHandle.swift
//  dogbreedClassifier
//
//  Created by Tucker on 7/23/19.
//  Copyright © 2019 Tucker. All rights reserved.
//

import Foundation
import UIKit

// extension to present UIAlertController to user

extension Error {
    
    // Display UIAlert with error
    /// - Parameters:
    ///   - UIViewController : view controller to display the error
    
    func alert(with controller: UIViewController) {
        let alertController = UIAlertController(title: nil , message: "\(self.localizedDescription)", preferredStyle: .alert)
        let okAction = UIAlertAction(title:"Dismiss", style: .default, handler: nil)
        alertController.addAction(okAction)
        controller.present(alertController,animated: true,completion: nil)
    }
}

