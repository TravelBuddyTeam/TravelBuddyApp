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
    var username : String!
    var userRatingPFObj : PFObject!
    
    @IBOutlet weak var friendRequestLabel: UILabel!
    @IBOutlet weak var friendRequestButton: UIButton!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var currentRatingImageView: UIImageView!
    @IBOutlet var parentView: UIView!
    var initialY: CGFloat!
    var offset: CGFloat!
    
    @IBOutlet weak var ratingControlStackView: RatingControl!
    @IBOutlet weak var reviewTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // round image
        profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2.0
        self.profileImageView.layer.masksToBounds = true
        
        // how much to move view up
        initialY = parentView.frame.origin.y
        offset = -150
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(self.KeyboardShowNotification(notification:)),
        name: UIResponder.keyboardWillShowNotification,
        object: nil)
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(self.KeyboardHideNotification(notification:)),
        name: UIResponder.keyboardWillHideNotification,
        object: nil)
        

        // Fill data
        FillData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        
        // Get user rating
        let query = PFQuery(className:"Rating")
        query.whereKey("user", equalTo: user!)
        query.limit = 1
        
        query.findObjectsInBackground { (ratings: [PFObject]?, error: Error?) in
            if ratings != nil {
                if ratings?.count == 0 {
                    // Create rating data for the user
                    let ratingPFObj = PFObject(className: "Rating")
                    ratingPFObj["user"] = self.user
                    ratingPFObj.saveInBackground(block: {(success, error) in
                        if (success) {
                            // Set Rating control's user rating object
                            self.ratingControlStackView.userRatingPFObj = ratingPFObj
                            self.userRatingPFObj = ratingPFObj
                            print("here")
                        } else {
                            print("Error: \(error?.localizedDescription ?? "unknown")")
                        }
                    })
                    self.currentRatingImageView.image = UIImage(named: "0star")
                    self.ratingCountLabel.text = "(0 rated)"
                } else {
                    let rating = ratings![0]
                    // Set Rating control's user rating object
                    self.ratingControlStackView.userRatingPFObj = rating
                    
                    self.userRatingPFObj = rating
                    
                    var ratingUsersCount = self.userRatingPFObj!.value(forKey: "numUsers") as? Double ?? 1
                    let ratingValue = self.userRatingPFObj!.value(forKey: "rating") as? Double ?? 0
                    if ratingUsersCount == 0 {
                        ratingUsersCount = 1
                        self.ratingCountLabel.text = "(0 rated)"
                    } else {
                        self.ratingCountLabel.text = "(\(Int(ratingUsersCount)) rated)"
                    }
                    let convertedRating = Int((ratingValue / (ratingUsersCount)))
                    
                    // Update rating Image
                    if convertedRating == 5 {
                        self.currentRatingImageView.image = UIImage(named: "5star")
                    } else if convertedRating == 4 {
                        self.currentRatingImageView.image = UIImage(named: "4star")
                    } else if convertedRating == 3 {
                        self.currentRatingImageView.image = UIImage(named: "3star")
                    } else if convertedRating == 2 {
                        self.currentRatingImageView.image = UIImage(named: "2star")
                    } else if convertedRating == 1 {
                        self.currentRatingImageView.image = UIImage(named: "1star")
                    } else {
                        self.currentRatingImageView.image = UIImage(named: "0star")
                    }
                }
            } else {
                print("Error: \(error?.localizedDescription ?? "unknown")")
            }
        }
        
        let query1 = PFQuery(className:"FriendRequest")
        query1.whereKey("fromUser", equalTo: PFUser.current()!)
        query1.whereKey("toUser", equalTo: user!)
        
        let query2 = PFQuery(className:"FriendRequest")
        query2.whereKey("fromUser", equalTo: user!)
        query2.whereKey("toUser", equalTo: PFUser.current()!)
        
        let query3 = PFQuery.orQuery(withSubqueries: [query1, query2])
        
        query3.limit = 1
        
        query3.findObjectsInBackground { (requests: [PFObject]?, error: Error?) in
            if requests != nil {
                if requests!.count == 0 {
                    self.friendRequestLabel.text = "Add Friend"
                    self.friendRequestButton.setBackgroundImage(UIImage(systemName: "person.badge.plus"), for: UIControl.State.normal)
                } else {
                    let friendRequest = requests![0]
                    
                    if (friendRequest.value(forKey: "status") as! Bool) {
                        // Unfriend
                        self.friendRequestLabel.text = "Unfriend"
                        self.friendRequestButton.setBackgroundImage(UIImage(systemName: "person.badge.minus"), for: UIControl.State.normal)
                    } else {
                        if (friendRequest["fromUser"] as? PFObject)?.objectId == PFUser.current()?.objectId {
                            // cancel request
                            self.friendRequestLabel.text = "Cancel Request"
                            self.friendRequestButton.setBackgroundImage(UIImage(systemName: "person.crop.circle.badge.xmark"), for: UIControl.State.normal)
                        } else {
                            // Accept Request
                            self.friendRequestLabel.text = "Accept"
                            self.friendRequestButton.setBackgroundImage(UIImage(systemName: "person.crop.circle.badge.checkmark"), for: UIControl.State.normal)
                        }
                    }
                }
            } else {
                print("Error: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }
    
    @IBAction func onBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onFriendRequestButton(_ sender: Any) {
        
        let query1 = PFQuery(className:"FriendRequest")
        query1.whereKey("fromUser", equalTo: PFUser.current()!)
        query1.whereKey("toUser", equalTo: user!)
        
        let query2 = PFQuery(className:"FriendRequest")
        query2.whereKey("fromUser", equalTo: user!)
        query2.whereKey("toUser", equalTo: PFUser.current()!)
        
        let query = PFQuery.orQuery(withSubqueries: [query1, query2])
        
        query.limit = 1
        
        query.findObjectsInBackground { (requests: [PFObject]?, error: Error?) in
            if requests != nil {
                if requests!.count == 0 {
                    // send friend request
                    let newFriendRequest = PFObject(className: "FriendRequest")
                    newFriendRequest["fromUser"] = PFUser.current()
                    newFriendRequest["toUser"] = self.user
                    newFriendRequest["status"] = false
                    newFriendRequest.saveInBackground(block: {(success, error) in
                        if success {
                            self.friendRequestLabel.text = "Cancel Request"
                            self.friendRequestButton.setBackgroundImage(UIImage(systemName: "person.crop.circle.badge.xmark"), for: UIControl.State.normal)
                        }
                    })
                } else {
                    let friendRequest = requests![0]
                    
                    if (friendRequest["fromUser"] as? PFObject)?.objectId == PFUser.current()?.objectId {
                        
                        // Delete friend request
                        friendRequest.deleteInBackground(block: {(success, error) in
                            if success {
                                self.friendRequestLabel.text = "Add Friend"
                                self.friendRequestButton.setBackgroundImage(UIImage(systemName: "person.badge.plus"), for: UIControl.State.normal)
                            }
                        })
                    } else {
                        // Accept friend request
                        friendRequest.setValue(true, forKey: "status")
                        friendRequest.saveInBackground(block: {(success, error) in
                            if success {
                                // Unfriend
                                self.friendRequestLabel.text = "Unfriend"
                                self.friendRequestButton.setBackgroundImage(UIImage(systemName: "person.badge.minus"), for: UIControl.State.normal)
                            }
                        })
                    }
                }
            } else {
                print("Error: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }
    
    @IBAction func onChatButton(_ sender: Any) {
    }
    
    @IBAction func onViewPhotosButton(_ sender: Any) {
    }
    
    @IBAction func onViewTravelsButton(_ sender: Any) {
    }
    
    @objc func KeyboardShowNotification(notification: NSNotification) {
        parentView.frame.origin.y = initialY + offset
    }
    
    @objc func KeyboardHideNotification(notification: NSNotification) {
        parentView.frame.origin.y = initialY
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
