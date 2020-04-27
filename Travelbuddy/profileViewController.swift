//
//  profileViewController.swift
//  Travelbuddy
//
//  Created by Steven Carey on 4/27/20.
//  Copyright © 2020 Travel Buddy Team. All rights reserved.
//

import UIKit
import Parse

class profileViewController: UIViewController {
    

    @IBOutlet weak var locationsCountLabel: UILabel!
    @IBOutlet weak var friendsCountLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUser = PFUser.current()
        
        userNameLabel.text = currentUser?.username
        //friendsCountLabel.text = currentUser?.friendsCount as? String
        //locationsCountLabel.text = currentUser?.locationsCount as? String
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
