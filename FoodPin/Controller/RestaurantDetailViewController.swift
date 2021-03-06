//
//  RestaurantDetailViewController.swift
//  FoodPin
//
//  Created by Roger Florat on 09/04/18.
//  Copyright © 2018 Roger Florat. All rights reserved.
//

import UIKit
import MapKit

class RestaurantDetailViewController: UIViewController {
    
    @IBOutlet var tableView:UITableView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var restaurantImageView:UIImageView!
    
    var restaurant: RestaurantMO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restaurantImageView.image = UIImage(data: (restaurant.image as Data?)!)
        
        tableView.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 0.2)
        tableView.separatorColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 0.8)        
        tableView.estimatedRowHeight = 36.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Display the restaurant name in the navigation bar title
        title = restaurant.name
        
        // Tap Gesture Recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:
            #selector(showMap))
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        // Adding an Annotation to the Non-interactive Map
        addingAnnotationToMap()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showReview" {
            let destinationController = segue.destination as! ReviewViewController
            destinationController.restaurant = restaurant
        } else if segue.identifier == "showMap" {
            let destinationController = segue.destination as! MapViewController
            destinationController.restaurant = restaurant
        }
    }
    
    func addingAnnotationToMap() {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(restaurant.location!) { (placemarks, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let placemarks = placemarks {
                
                // Get the first placemark
                let placemark = placemarks[0]
                
                // Add annotation
                let annotation = MKPointAnnotation()
                
                if let location = placemark.location {
                    
                    // Display the annotation
                    annotation.coordinate = location.coordinate
                    self.mapView.addAnnotation(annotation)
                    
                    // Set the zoom level
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 250, 250)
                    self.mapView.setRegion(region, animated: false)
                }
            }
            
        }
        
    }
    
    @objc func showMap() {
        performSegue(withIdentifier: "showMap", sender: self)
    }
    
    @IBAction func close(segue:UIStoryboardSegue) {}
    
    @IBAction func ratingButtonTapped(segue: UIStoryboardSegue) {
        if let rating = segue.identifier {
            self.restaurant.isVisited = true
            
            switch rating {
            case "great": restaurant.rating = "Absolutely love it! Must try."
            case "good": restaurant.rating = "Pretty good."
            case "dislike": restaurant.rating = "I don't like it."
            default: break
            }
        }
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            appDelegate.saveContext()
        }
        
        tableView.reloadData()
    }
    
}

extension RestaurantDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RestaurantDetailTableViewCell
        
        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = NSLocalizedString("Name", comment: "Name Field")
            cell.valueLabel.text = restaurant.name
        case 1:
            cell.fieldLabel.text = NSLocalizedString("Type", comment: "Type Field")
            cell.valueLabel.text = restaurant.type
        case 2:
            cell.fieldLabel.text = NSLocalizedString("Location", comment: "Location/Address Field")
            cell.valueLabel.text = restaurant.location
        case 3:
            cell.fieldLabel.text = NSLocalizedString("Phone", comment: "Phone Field")
            cell.valueLabel.text = restaurant.phone
        case 4:
            cell.fieldLabel.text = NSLocalizedString("Been here", comment: "Have you been here Field")
            cell.valueLabel.text = (restaurant.isVisited) ? NSLocalizedString("Yes, I've been here before. \(restaurant.rating ?? "")", comment: "Yes, I've been here before") : NSLocalizedString("No", comment: "No, I haven't been here")
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
}


