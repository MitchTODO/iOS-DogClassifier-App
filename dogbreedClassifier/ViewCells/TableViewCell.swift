//
//  TableViewCell.swift
//  dogbreedClassifier
//
//  Created by Tucker on 7/16/19.
//  Copyright © 2019 Tucker. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet var breedLabel: UILabel!
    

    @IBOutlet var precentLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
