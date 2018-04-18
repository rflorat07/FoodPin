//
//  RestaurantTableViewController.swift
//  FoodPin
//
//  Created by Roger Florat on 06/04/18.
//  Copyright © 2018 Roger Florat. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class RestaurantTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate {
    
    var restaurants: [RestaurantMO] = []
    var searchResults:[RestaurantMO] = []
    var searchController:UISearchController!
    var fetchResultController: NSFetchedResultsController<RestaurantMO>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable Self Sizing Cells
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Search bar added in the header of table view
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        // Customizing the Appearance of the Search Bar

        searchController.searchBar.barTintColor = #colorLiteral(red: 0.8549019608, green: 0.3921568627, blue: 0.2745098039, alpha: 1)
        searchController.searchBar.backgroundColor = #colorLiteral(red: 0.8549019608, green: 0.3921568627, blue: 0.2745098039, alpha: 1)
        searchController.searchBar.tintColor = .white
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.placeholder = "Search restaurants..."
   
        tableView.tableHeaderView = searchController.searchBar
        
        // Fetch data from data store
        fetchRestaurantsData()
        
        // Peek and Pop
        initPeekAndPop()
        
       // Notification
        prepareNotification()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            return
        }
        
        if let pageViewController = storyboard?.instantiateViewController(withIdentifier: "WalkthroughController") as? WalkthroughPageViewController {
            present(pageViewController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                let destinationController = segue.destination as! RestaurantDetailViewController
                
                destinationController.restaurant = (searchController.isActive) ?
                    searchResults[indexPath.row] : restaurants[indexPath.row]
                destinationController.hidesBottomBarWhenPushed = true
            }
        }
    }
    
    
    // MARK: - Notification
    func prepareNotification() {
        
        // Make sure the restaurant array is not empty
        if restaurants.count <= 0 { return }
        
        // Pick a restaurant randomly
        let randomNum = Int(arc4random_uniform(UInt32(restaurants.count)))
        let suggestedRestaurant = restaurants[randomNum]
        
        // Create the user notification
        let content = UNMutableNotificationContent()
        content.title = "Restaurant Recommendation"
        content.subtitle = "Try new food today"
        content.body = "I recommend you to check out \(suggestedRestaurant.name!). The restaurant is one of your favorites. It is located at \(suggestedRestaurant.location!). Would you like to give it a try?"
        content.sound = UNNotificationSound.default()
        content.userInfo = ["phone": suggestedRestaurant.phone!]
        
        // Create notification attachment - image
        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFileURL = tempDirURL.appendingPathComponent("suggested-restaurant.jpg")
        
        if let image = UIImage(data: suggestedRestaurant.image! as Data) {
            try? UIImageJPEGRepresentation(image, 1.0)?.write(to: tempFileURL)
            if let restaurantImage = try? UNNotificationAttachment(identifier:
                "restaurantImage", url: tempFileURL, options: nil) {
                content.attachments = [restaurantImage]
            }
        }
        
        // Creating and Registering Custom Actions
        let categoryIdentifer = "foodpin.restaurantaction"
        
        let cancelAction = UNNotificationAction(identifier: "foodpin.cancel", title: "Later", options: [])
        let reservationAction = UNNotificationAction(identifier: "foodpin.makeReservation", title: "Reserve a table", options: [.foreground])
        
        let category = UNNotificationCategory(identifier: categoryIdentifer, actions: [reservationAction, cancelAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        content.categoryIdentifier = categoryIdentifer
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        let request = UNNotificationRequest(identifier: "foodpin.restaurantSuggestion", content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // MARK: - Peek and Pop
    func initPeekAndPop() {
        if(traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: view)
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        guard let restaurantDetailViewController = storyboard?.instantiateViewController(withIdentifier: "RestaurantDetailViewController") as? RestaurantDetailViewController else { return nil }
        
        let selectedRestaurant = restaurants[indexPath.row]
        restaurantDetailViewController.restaurant = selectedRestaurant
        restaurantDetailViewController.preferredContentSize = CGSize(width: 0.0, height: 450.0)
        
        previewingContext.sourceRect = cell.frame
        
        return restaurantDetailViewController
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    // MARK: - Search Results
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }
    
    // MARK: - Helper methods
    func filterContent(for searchText: String) {
        searchResults = restaurants.filter({ (restaurant) -> Bool in
            if let name = restaurant.name, let location = restaurant.location {
                let isMatch = name.localizedCaseInsensitiveContains(searchText) || location.localizedCaseInsensitiveContains(searchText)
                return isMatch
            }
            return false
        })
    }
    
    // MARK: - Change Content
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?, for type:
        NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            tableView.reloadData()
        }
        if let fetchedObjects = controller.fetchedObjects {
            restaurants = fetchedObjects as! [RestaurantMO]
        }
    }
    
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: - Fetch restaurants data from data store
    func fetchRestaurantsData() {
        
        let fetchRequest: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    restaurants = fetchedObjects
                }
                
            } catch {
                print("Fetch restaurants data error: ", error)
            }
        }
        
    }
    
    // MARK: - Action
    @IBAction func unwindToHomeScreen(segue:UIStoryboardSegue) {
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return searchResults.count
        } else {
            return restaurants.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RestaurantTableViewCell
        
        // Determine if we get the restaurant from search result or the original array
        let restaurant = (searchController.isActive) ? searchResults[indexPath.row] : restaurants[indexPath.row]
        
        // Configure the cell...
        
        cell.nameLabel.text = restaurant.name
        cell.locationLabel.text = restaurant.location
        cell.typeLabel.text = restaurant.type
        cell.thumbnailImageView.image = UIImage(data: restaurant.image! )
        cell.accessoryType = restaurant.isVisited ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searchController.isActive {
            return false
        } else {
            return true
        }
    }
   
    // MARK: - Swipe cell
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            // Delete the row from the data store
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let restaurantToDelete = self.fetchResultController.object(at: indexPath)
                context.delete(restaurantToDelete)
                
                appDelegate.saveContext()
            }
            
            // Call completion handler with true to indicate
            completionHandler(true)
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (action, sourceView, completionHandler) in
            let defaultText = "Just checking in at " + self.restaurants[indexPath.row].name!
            
            let activityController: UIActivityViewController
            
            if let restaurantImage = self.restaurants[indexPath.row].image,
                let imageToShare = UIImage(data: restaurantImage as Data) {
                activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
            } else  {
                activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            }
            
            if let popoverController = activityController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            
            self.present(activityController, animated: true, completion: nil)
            completionHandler(true)
        }
        
        // Customize the action buttons
        deleteAction.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        deleteAction.image = UIImage(named: "delete")
        shareAction.backgroundColor = UIColor(red: 254.0/255.0, green: 149.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        shareAction.image = UIImage(named: "share")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        
        return swipeConfiguration
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let checkInAction = UIContextualAction(style: .normal, title: "Check-in") { (action, sourceView, completionHandler) in
            self.restaurants[indexPath.row].isVisited = (self.restaurants[indexPath.row].isVisited) ? false : true
            completionHandler(true)
        }
        
        // Customize the action button
        checkInAction.backgroundColor = UIColor(red: 39.0/255.0, green: 174.0/255.0, blue: 96.0/255.0, alpha: 1.0)
        checkInAction.image = self.restaurants[indexPath.row].isVisited ? UIImage(named: "undo") : UIImage(named: "tick")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [checkInAction])
        
        return swipeConfiguration
    }
    
}













