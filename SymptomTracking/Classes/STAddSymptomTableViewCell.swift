//
//  STAddSymptomTableViewCell.swift
//  SymptomTracking
//
//  Created by James Kizer on 10/23/18.
//

import UIKit

class STAddSymptomTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    
    var onTap:((STAddSymptomTableViewCell) -> ())?
    
    @IBAction func buttonTap(_ sender: Any) {
        self.onTap?(self)
    }
    
}
