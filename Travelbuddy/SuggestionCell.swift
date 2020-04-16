//
//  SuggestionCell.swift
//  Travelbuddy
//
//  Created by Daniel Adu-Djan on 4/15/20.
//  Copyright © 2020 Travel Buddy Team. All rights reserved.
//

import UIKit

class SuggestionCell: UITableViewCell {

    
    @IBOutlet weak var locationNameLabel: UILabel!
    
    @IBOutlet weak var locationAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
