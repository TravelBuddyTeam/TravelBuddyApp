//
//  FriendsTableViewCell.swift
//  Travelbuddy
//
//  Created by Steven Carey on 4/19/20.
//  Copyright © 2020 Travel Buddy Team. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    
    @IBOutlet weak var friendStateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // round image
        friendImageView.layer.cornerRadius = self.friendImageView.frame.width / 2.0
        self.friendImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
