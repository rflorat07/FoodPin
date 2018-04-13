//
//  RestaurantTableViewCell.swift
//  FoodPin
//
//  Created by Roger Florat on 06/04/18.
//  Copyright © 2018 Roger Florat. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
  
    }
}
