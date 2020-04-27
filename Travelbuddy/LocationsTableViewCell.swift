//
//  LocationsTableViewCell.swift
//  Travelbuddy
//
//  Created by Steven Carey on 4/19/20.
//  Copyright © 2020 Travel Buddy Team. All rights reserved.
//

import UIKit
import Parse

class LocationsTableViewCell: UITableViewCell {

    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationDescriptionLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var visitedButton: UIButton!
    
    var location : PFObject!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        visitedButton.titleLabel?.textColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateButton (visited: Bool) {
        if visited {
            // change UI
            visitedButton.backgroundColor = UIColor.systemGreen
            visitedButton.setTitle("Mark Not Visited", for: .normal)
        } else {
            // change UI
            visitedButton.backgroundColor = UIColor.lightGray
            visitedButton.setTitle("Mark Visited", for: .normal)
        }
    }

    @IBAction func onVisitedButton(_ sender: Any) {
        let visited = location.value(forKey: "visited") as! Bool
        
        if visited {
            // set location as visited
            location["visited"] = false
        } else {
            // set location as not visited
            location["visited"] = true
        }
        location.saveInBackground()
        updateButton(visited: !visited)
    }
}
