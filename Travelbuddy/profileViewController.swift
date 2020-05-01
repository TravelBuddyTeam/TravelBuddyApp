//
//  profileViewController.swift
//  Travelbuddy
//
//  Created by Steven Carey on 4/27/20.
//  Copyright © 2020 Travel Buddy Team. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class profileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var currentUser : PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = PFUser.current()
        
        // pull profile image
        if currentUser.value(forKey: "profileImage") != nil {
            let profileImageFile = currentUser.value(forKey: "profileImage") as! PFFileObject
            let profileImageUrlString = profileImageFile.url!
            let profileImageUrl = URL(string: profileImageUrlString)!
            imageView.af_setImage(withURL: profileImageUrl)
        }
        
        userNameLabel.text = currentUser?.value(forKey: "username") as? String

    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onProfileImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        imageView.image = scaledImage
        
        // save user image
        let profileImageData = imageView.image!.pngData()
        let profileImageFile = PFFileObject(name: "image.png", data: profileImageData!)
        currentUser["profileImage"] = profileImageFile
        currentUser.saveInBackground()
        
        dismiss(animated: true, completion: nil)
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
