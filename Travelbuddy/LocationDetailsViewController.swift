//
//  LocationDetailsViewController.swift
//  Travelbuddy
//
//  Created by Daniel Adu-Djan on 4/27/20.
//  Copyright © 2020 Travel Buddy Team. All rights reserved.
//

import UIKit
import MapKit
import Parse
import AlamofireImage

class LocationDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var location : PFObject!
    
    var initialY: CGFloat!
    var offset: CGFloat!
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var fieldsSuperView: UIView!
    @IBOutlet weak var heroLocationImageView: UIImageView!
    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var locationAddressTextField: UITextField!
    @IBOutlet weak var locationDescriptionTextField: UITextView!
    @IBOutlet weak var locationVisitedSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateButton.layer.cornerRadius = 15

        // Do any additional setup after loading the view.
        FillData()
        
        // Set fields superView params
        initialY = fieldsSuperView.frame.origin.y
        offset = -70
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(self.KeyboardShowNotification(notification:)),
        name: UIResponder.keyboardWillShowNotification,
        object: nil)
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(self.KeyboardHideNotification(notification:)),
        name: UIResponder.keyboardWillHideNotification,
        object: nil)
    }

    @IBAction func onVisitedToggle(_ sender: Any) {
        if locationVisitedSegmentedControl.selectedSegmentIndex == 0 {
            location["visited"] = true
        } else {
            location["visited"] = false
        }
        location.saveInBackground()
    }
    
    func FillData() {
        let visited = location.value(forKey: "visited") as! Bool
        
        if location.value(forKey: "locationImage") != nil {
            let heroImageFile = location.value(forKey: "locationImage") as! PFFileObject
            let heroImageUrlString = heroImageFile.url!
            let heroImageUrl = URL(string: heroImageUrlString)!
            heroLocationImageView.af_setImage(withURL: heroImageUrl)
        }
        locationNameTextField.text = location.value(forKey: "name") as? String
        locationAddressTextField.text = location.value(forKey: "address") as? String
        locationDescriptionTextField.text = location.value(forKey: "synopsis") as? String
        
        if (visited) {
            locationVisitedSegmentedControl.selectedSegmentIndex = 0
        } else {
            locationVisitedSegmentedControl.selectedSegmentIndex = 1
        }
    }
    
    @IBAction func onUpdateButton(_ sender: Any) {
        location["name"] = locationNameTextField.text
        location["address"] = locationAddressTextField.text
        location["synopsis"] = locationDescriptionTextField.text
        location.saveInBackground()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onHeroTap(_ sender: Any) {
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
        
        heroLocationImageView.image = scaledImage
        
        // save image
        let locationImageData = heroLocationImageView.image!.pngData()
        let locationImageFile = PFFileObject(name: "image.png", data: locationImageData!)
        location["locationImage"] = locationImageFile
        location.saveInBackground()
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func KeyboardShowNotification(notification: NSNotification) {
        fieldsSuperView.frame.origin.y = initialY + offset
    }
    
    @objc func KeyboardHideNotification(notification: NSNotification) {
        fieldsSuperView.frame.origin.y = initialY
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
