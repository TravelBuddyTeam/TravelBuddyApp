//
//  FriendsViewController.swift
//  Travelbuddy
//
//  Created by Steven Carey on 4/19/20.
//  Copyright © 2020 Travel Buddy Team. All rights reserved.
//

import UIKit
import Parse

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    var friendRequests : [PFObject] = []
    var users : [PFObject] = []
    var toRequests : [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self

        // Do any additional setup after loading the view.
        GetFriends()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        GetFriends()
    }
    
    func GetFriends() {
        let query1 = PFQuery(className:"FriendRequest")
        query1.whereKey("fromUser", equalTo: PFUser.current()!)
        
        let query2 = PFQuery(className:"FriendRequest")
        query2.whereKey("toUser", equalTo: PFUser.current()!)
        
        let query3 = PFQuery.orQuery(withSubqueries: [query1, query2])
        query3.includeKeys(["fromUser", "fromUser.username", "fromUser.profileImage", "toUser", "toUser.username", "toUser.profileImage"])
        
        query3.findObjectsInBackground { (requests: [PFObject]?, error: Error?) in
            if requests != nil {
                self.friendRequests = requests!
                print(self.friendRequests.count)
                self.friendsTableView.reloadData()
            } else {
                print("Error: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as! FriendsTableViewCell
        
        //set values in cell
        let friendRequest = friendRequests[indexPath.row]
        var friend : PFObject!
        
        if (friendRequest["fromUser"] as! PFObject).objectId == PFUser.current()?.objectId {
            print("user sent request")
            friend = friendRequest["toUser"] as? PFObject
            toRequests.append(true)
        } else if  (friendRequest["toUser"] as! PFObject).objectId == PFUser.current()?.objectId {
            print("user received request")
            friend = friendRequest["fromUser"] as? PFObject
            toRequests.append(false)
        }
        
        let userName = friend.value(forKey: "username") as? String
        cell.friendNameLabel.text = userName
        
        let friendStatus = (friendRequest.value(forKey: "status") as? Bool)!
        if friendStatus {
            cell.friendStateLabel.text = ""
        } else {
            cell.friendStateLabel.text = "Pending"
        }

        if friend.value(forKey: "profileImage") != nil {
            let imageFile = friend.value(forKey: "profileImage") as! PFFileObject
            let imageUrlString = imageFile.url!
            let imageUrl = URL(string: imageUrlString)!
            cell.friendImageView.af_setImage(withURL: imageUrl)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendDetailViewControllerSegue" {
            let cell = sender as! UITableViewCell
            let indexPath = friendsTableView.indexPath(for: cell)
            if  indexPath != nil {
                let destinationNavigationController = segue.destination as! UINavigationController
                let detailsViewController = destinationNavigationController.topViewController as! FriendDetailsViewController
                
                let friendRequest = friendRequests[indexPath!.row]
                
                if toRequests[indexPath!.row] {
                    detailsViewController.user = friendRequest["toUser"] as? PFObject
                } else {
                    detailsViewController.user = friendRequest["fromUser"] as? PFObject
                }
            }
        }
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
