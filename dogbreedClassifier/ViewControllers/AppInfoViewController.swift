//
//  AppInfoViewController.swift
//  dogbreedClassifier
//
//  Created by Tucker on 8/2/19.
//  Copyright © 2019 Tucker. All rights reserved.
//

import UIKit

class AppInfoViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var pp: UILabel!
    @IBOutlet weak var pp2: UILabel!
    @IBOutlet weak var pp6: UILabel!
    @IBOutlet weak var pp7: UILabel!
    @IBOutlet weak var pp8: UILabel!
    @IBOutlet weak var termConditions: UILabel!
    @IBOutlet weak var termConditions2: UILabel!
    @IBOutlet weak var termConditions3: UILabel!
    @IBOutlet weak var agreementButton: UISegmentedControl!
    @IBOutlet weak var about: UILabel!
    
    // MARK: - IBAction
    
    /// IBActions agree UIbutton
    ///
    /// - Parameters:
    ///   - sender : Any
    @IBAction func agreed(_ sender: Any) {
        let pressed = sender as! UISegmentedControl
        let title = pressed.titleForSegment(at: pressed.selectedSegmentIndex)!
        let defaults = UserDefaults.standard
        if title == "Agree"{
            defaults.set(true, forKey: "Agreed")
            self.navigationController?.isNavigationBarHidden = false
            navigationController?.popToRootViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }else{
            defaults.set(false, forKey: "Agreed")
            self.navigationController?.isNavigationBarHidden = true
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // change font size
        let font = UIFont.systemFont(ofSize: 20)
        agreementButton.setTitleTextAttributes([NSAttributedString.Key.font: font],for: .normal)
        // set text within UIlabels
        pp.text = privacyPolicyPart1
        pp2.text = privacyPolicyPart2
        pp6.text = privacyPolicyPart6
        pp7.text = privacyPolicyPart7
        pp8.text = privacyPolicyPart8
        termConditions.text = termsAndConditions
        termConditions2.text = termsAndConditions2
        termConditions3.text = termsAndConditions3
        about.text = aboutText
        // get app default value
        let defaults = UserDefaults.standard
        let hasAgreed = defaults.bool(forKey: "Agreed")
        if hasAgreed == false {
            self.navigationController?.isNavigationBarHidden = true
        }else{
            agreementButton.selectedSegmentIndex = 1
        }
    
        // set view title
        self.title = "Privacy Policy / Term And Conditions"
        
    }

}
