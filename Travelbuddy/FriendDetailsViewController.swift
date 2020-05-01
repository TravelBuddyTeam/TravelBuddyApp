//
//  FriendDetailsViewController.swift
//  Travelbuddy
//
//  Created by Daniel Adu-Djan on 4/30/20.
//  Copyright © 2020 Travel Buddy Team. All rights reserved.
//

import UIKit
import Parse

class FriendDetailsViewController: UIViewController {

    var user : PFObject!
    
    @IBOutlet weak var reviewTextField: UITextField!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // round image
        profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2.0
        self.profileImageView.layer.masksToBounds = true
        
        // Fill data
        FillData()
    }
    
    func FillData() {
        // Profile Image
        if user.value(forKey: "profileImage") != nil {
            let profileImageFile = user.value(forKey: "profileImage") as! PFFileObject
            let profileImageUrlString = profileImageFile.url!
            let profileImageUrl = URL(string: profileImageUrlString)!
            profileImageView.af_setImage(withURL: profileImageUrl)
        }
        
        // Username
        usernameLabel.text = user.value(forKey: "username") as? String
    }
    
    @IBAction func onBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onFriendRequestButton(_ sender: Any) {
    }
    
    @IBAction func onChatButton(_ sender: Any) {
    }
    
    @IBAction func onViewPhotosButton(_ sender: Any) {
    }
    
    @IBAction func onViewTravelsButton(_ sender: Any) {
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
