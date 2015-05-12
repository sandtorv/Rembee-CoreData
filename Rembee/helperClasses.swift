//
//  helperClasses.swift
//  Rembee
//
//  Created by Sebastian Sandtorv on 01/05/15.
//  Copyright (c) 2015 Protodesign. All rights reserved.
//

import Foundation
import UIKit

class tableCell: UITableViewCell {
    
    @IBOutlet weak var title:  UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}