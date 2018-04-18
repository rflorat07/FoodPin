//
//  WalkthroughContentViewController.swift
//  FoodPin
//
//  Created by Roger Florat on 13/04/18.
//  Copyright © 2018 Roger Florat. All rights reserved.
//

import UIKit

class WalkthroughContentViewController: UIViewController {
    
    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var forwardButton: UIButton!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var contentImageView: UIImageView!
    
    
    var index = 0
    var heading = ""
    var imageFile = ""
    var content = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headingLabel.text = heading
        contentLabel.text = content
        pageControl.currentPage = index
        contentImageView.image = UIImage(named: imageFile)
        
        switch index {
            
        case 0...1: forwardButton.setTitle("NEXT", for: .normal)
        case 2: forwardButton.setTitle("DONE", for: .normal)
        default: break
            
        }
    }
    
    
    // Add Quick Actions
    func addQuickActions() {
        if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            let bundleIdentifier = Bundle.main.bundleIdentifier
            let shortcutItem1 = UIApplicationShortcutItem(type: "\(String(describing: bundleIdentifier)).OpenFavorites", localizedTitle: "Show Favorites",
                localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "favorite-shortcut"), userInfo: nil)
            let shortcutItem2 = UIApplicationShortcutItem(type: "\(String(describing: bundleIdentifier)).OpenDiscover", localizedTitle: "Discover restaurants", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "discover-shortcut"), userInfo: nil)
            let shortcutItem3 = UIApplicationShortcutItem(type: "\(String(describing: bundleIdentifier)).NewRestaurant", localizedTitle: "New Restaurant",localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
            UIApplication.shared.shortcutItems = [shortcutItem1, shortcutItem2,shortcutItem3]
        }
    }
    
    @IBAction func nextButtonTapped(sender: UIButton) {
        switch index {
        case 0...1:
            let pageViewController = parent as! WalkthroughPageViewController
            pageViewController.forward(index: index)
            
        case 2:
            addQuickActions()
            UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
            dismiss(animated: true, completion: nil)
            
        default: break
        }
    }
    
}
