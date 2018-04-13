//
//  AddRestaurantController.swift
//  FoodPin
//
//  Created by Roger Florat on 12/04/18.
//  Copyright © 2018 Roger Florat. All rights reserved.
//

import UIKit

class AddRestaurantController: UITableViewController {
    
    @IBOutlet var nameTextField:UITextField!
    @IBOutlet var typeTextField:UITextField!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var locationTextField:UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet var noButton:UIButton!
    @IBOutlet var yesButton:UIButton!
    
    var isVisited = true
    var restaurant: RestaurantMO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                
                present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        if nameTextField.text == "" || typeTextField.text == "" || locationTextField.text == "" {
            presentAlertController()
        } else {
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                
                restaurant = RestaurantMO(context: appDelegate.persistentContainer.viewContext)
                
                restaurant.name = nameTextField.text
                restaurant.type = typeTextField.text
                restaurant.phone = phoneTextField.text
                restaurant.location = locationTextField.text
                
                restaurant.isVisited = isVisited
                
                if let restaurantImage = photoImageView.image {
                    if let imageData = UIImagePNGRepresentation(restaurantImage) {
                        restaurant.image = NSData(data: imageData) as Data
                    }
                }
                
                print("Saving data to context ...")
                
                appDelegate.saveContext()
                
            }
            
            
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func toggleBeenHereButton(sender: UIButton) {
        
        if sender == yesButton {
            isVisited = true
            yesButton.backgroundColor = #colorLiteral(red: 0.8549019608, green: 0.3921568627, blue: 0.2745098039, alpha: 1)
            noButton.backgroundColor = #colorLiteral(red: 0.6588235294, green: 0.7137254902, blue: 0.7843137255, alpha: 1)
        } else if sender == noButton {
            isVisited = false
            yesButton.backgroundColor = #colorLiteral(red: 0.6588235294, green: 0.7137254902, blue: 0.7843137255, alpha: 1)
            noButton.backgroundColor = #colorLiteral(red: 0.8549019608, green: 0.3921568627, blue: 0.2745098039, alpha: 1)
        }
    }
    
    func presentAlertController() {
        let alertController = UIAlertController(title: "Oops", message: "We can't proceed because one of the fields is blank. Please note that all fields are required.", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

extension AddRestaurantController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photoImageView.image = selectedImage
            photoImageView.contentMode = .scaleToFill
            photoImageView.clipsToBounds = true
        }
        
        let leadingConstraint = NSLayoutConstraint(item: photoImageView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: photoImageView.superview, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true
        
        let trailingConstraint = NSLayoutConstraint(item: photoImageView,attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal,toItem: photoImageView.superview, attribute: NSLayoutAttribute.trailing,multiplier: 1, constant: 0)
        trailingConstraint.isActive = true
        
        let topConstraint = NSLayoutConstraint(item: photoImageView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: photoImageView.superview, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
        
        let bottomConstraint = NSLayoutConstraint(item: photoImageView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: photoImageView.superview, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
        
        dismiss(animated: true, completion: nil)
    }
    
}









